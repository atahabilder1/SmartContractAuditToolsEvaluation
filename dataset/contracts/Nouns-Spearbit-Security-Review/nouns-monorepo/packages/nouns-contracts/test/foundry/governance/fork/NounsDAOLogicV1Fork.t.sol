// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;

import 'forge-std/Test.sol';

import { DeployUtilsFork } from '../../helpers/DeployUtilsFork.sol';
import { NounsDAOLogicV3 } from '../../../../contracts/governance/NounsDAOLogicV3.sol';
import { NounsToken } from '../../../../contracts/NounsToken.sol';
import { NounsTokenFork } from '../../../../contracts/governance/fork/newdao/token/NounsTokenFork.sol';
import { NounsDAOExecutorV2 } from '../../../../contracts/governance/NounsDAOExecutorV2.sol';
import { NounsDAOLogicV1Fork } from '../../../../contracts/governance/fork/newdao/governance/NounsDAOLogicV1Fork.sol';
import { NounsDAOStorageV1Fork } from '../../../../contracts/governance/fork/newdao/governance/NounsDAOStorageV1Fork.sol';
import { NounsDAOForkEscrowMock } from '../../helpers/NounsDAOForkEscrowMock.sol';
import { NounsTokenLikeMock } from '../../helpers/NounsTokenLikeMock.sol';
import { NounsTokenLike } from '../../../../contracts/governance/NounsDAOInterfaces.sol';
import { ERC20Mock } from '../../helpers/ERC20Mock.sol';
import { MaliciousForkDAOQuitter } from '../../helpers/MaliciousForkDAOQuitter.sol';

abstract contract NounsDAOLogicV1ForkBase is DeployUtilsFork {
    NounsDAOLogicV1Fork dao;
    address timelock;
    NounsTokenFork token;
    address proposer = makeAddr('proposer');

    function setUp() public virtual {
        (address treasuryAddress, address tokenAddress, address daoAddress) = _deployForkDAO();
        dao = NounsDAOLogicV1Fork(daoAddress);
        token = NounsTokenFork(tokenAddress);
        timelock = treasuryAddress;

        // a block buffer so prop.startBlock - votingDelay might land on a valid block.
        // in the old way of calling getPriorVotes in vote casting.
        vm.roll(block.number + 1);

        vm.startPrank(token.minter());
        token.mint();
        token.transferFrom(token.minter(), proposer, 0);
        vm.stopPrank();

        vm.roll(block.number + 1);
    }

    function propose() internal returns (uint256) {
        return propose(address(1), 0, 'signature', '');
    }

    function propose(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data
    ) internal returns (uint256) {
        vm.prank(proposer);
        address[] memory targets = new address[](1);
        targets[0] = target;
        uint256[] memory values = new uint256[](1);
        values[0] = value;
        string[] memory signatures = new string[](1);
        signatures[0] = signature;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = data;
        return dao.propose(targets, values, signatures, calldatas, 'my proposal');
    }
}

contract NounsDAOLogicV1Fork_votingDelayBugFix_Test is NounsDAOLogicV1ForkBase {
    uint256 proposalId;
    uint256 creationBlock;

    function setUp() public override {
        super.setUp();

        proposalId = propose();
        creationBlock = block.number;

        vm.roll(block.number + dao.votingDelay() + 1);
    }

    function test_propose_savesCreationBlockAsExpected() public {
        assertEq(dao.proposals(proposalId).creationBlock, creationBlock);
    }

    function test_proposeAndCastVote_voteCountedAsExpected() public {
        vm.prank(proposer);
        dao.castVote(proposalId, 1);

        assertEq(dao.proposals(proposalId).forVotes, 1);
    }

    function test_proposeAndCastVote_editingVotingDelayDoesntChangeVoteCount() public {
        vm.startPrank(address(dao.timelock()));
        dao._setVotingDelay(dao.votingDelay() + 3);

        changePrank(proposer);
        dao.castVote(proposalId, 1);

        assertEq(dao.proposals(proposalId).forVotes, 1);
    }
}

contract NounsDAOLogicV1Fork_cancelProposalUnderThresholdBugFix_Test is NounsDAOLogicV1ForkBase {
    uint256 proposalId;

    function setUp() public override {
        super.setUp();

        vm.prank(timelock);
        dao._setProposalThresholdBPS(1_000);

        vm.startPrank(token.minter());
        for (uint256 i = 0; i < 9; ++i) {
            token.mint();
        }
        token.transferFrom(token.minter(), proposer, 1);
        vm.stopPrank();
        vm.roll(block.number + 1);

        proposalId = propose();
    }

    function test_cancel_nonProposerCanCancelWhenProposerBalanceEqualsThreshold() public {
        vm.prank(proposer);
        token.transferFrom(proposer, address(1), 1);
        vm.roll(block.number + 1);
        assertEq(token.getPriorVotes(proposer, block.number - 1), dao.proposalThreshold());

        vm.prank(makeAddr('not proposer'));
        dao.cancel(proposalId);

        assertTrue(dao.proposals(proposalId).canceled);
    }

    function test_cancel_nonProposerCanCancelWhenProposerBalanceIsLessThanThreshold() public {
        vm.startPrank(proposer);
        token.transferFrom(proposer, address(1), 0);
        token.transferFrom(proposer, address(1), 1);
        vm.roll(block.number + 1);
        assertEq(token.getPriorVotes(proposer, block.number - 1), dao.proposalThreshold() - 1);

        changePrank(makeAddr('not proposer'));
        dao.cancel(proposalId);

        assertTrue(dao.proposals(proposalId).canceled);
    }

    function test_cancel_nonProposerCannotCancelWhenProposerBalanceIsGtThreshold() public {
        assertEq(token.getPriorVotes(proposer, block.number - 1), dao.proposalThreshold() + 1);

        vm.startPrank(makeAddr('not proposer'));
        vm.expectRevert('NounsDAO::cancel: proposer above threshold');
        dao.cancel(proposalId);
    }
}

abstract contract ForkWithEscrow is NounsDAOLogicV1ForkBase {
    NounsDAOForkEscrowMock escrow;
    NounsTokenLike originalToken;
    NounsDAOLogicV3 originalDAO;

    address owner1 = makeAddr('owner1');

    function setUp() public virtual override {
        originalDAO = _deployDAOV3();
        originalToken = originalDAO.nouns();
        address originalMinter = originalToken.minter();

        // Minting original tokens
        vm.startPrank(originalMinter);
        originalToken.mint();
        originalToken.mint();
        originalToken.transferFrom(originalMinter, proposer, 1);
        originalToken.transferFrom(originalMinter, owner1, 2);

        // Escrowing original tokens
        changePrank(proposer);
        originalToken.setApprovalForAll(address(originalDAO), true);
        uint256[] memory proposerTokens = new uint256[](1);
        proposerTokens[0] = 1;
        originalDAO.escrowToFork(proposerTokens, new uint256[](0), '');

        changePrank(owner1);
        originalToken.setApprovalForAll(address(originalDAO), true);
        uint256[] memory owner1Tokens = new uint256[](1);
        owner1Tokens[0] = 2;
        originalDAO.escrowToFork(owner1Tokens, new uint256[](0), '');

        vm.stopPrank();

        (address treasuryAddress, address tokenAddress, address daoAddress) = _deployForkDAO(originalDAO.forkEscrow());

        dao = NounsDAOLogicV1Fork(daoAddress);
        token = NounsTokenFork(tokenAddress);
        timelock = treasuryAddress;
    }
}

contract NounsDAOLogicV1Fork_DelayedGovernance_Test is ForkWithEscrow {
    function setUp() public override {
        super.setUp();
    }

    function test_propose_givenTokenToClaim_reverts() public {
        vm.expectRevert(abi.encodeWithSelector(NounsDAOLogicV1Fork.WaitingForTokensToClaimOrExpiration.selector));
        propose();
    }

    function test_propose_givenPartialClaim_reverts() public {
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 1;
        vm.prank(proposer);
        token.claimFromEscrow(tokens);

        vm.expectRevert(abi.encodeWithSelector(NounsDAOLogicV1Fork.WaitingForTokensToClaimOrExpiration.selector));
        propose();
    }

    function test_propose_givenFullClaim_works() public {
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 1;
        vm.prank(proposer);
        token.claimFromEscrow(tokens);

        tokens[0] = 2;
        vm.prank(owner1);
        token.claimFromEscrow(tokens);

        // mining one block so proposer prior votes getter sees their tokens.
        vm.roll(block.number + 1);

        propose();
    }

    function test_propose_givenTokensToClaimAndDelayedGovernanceExpires_works() public {
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 1;
        vm.prank(proposer);
        token.claimFromEscrow(tokens);
        // mining one block so proposer prior votes getter sees their tokens.
        vm.roll(block.number + 1);

        vm.warp(dao.delayedGovernanceExpirationTimestamp());

        propose();
    }

    function test_quit_givenPartialClaim_reverts() public {
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 1;
        vm.startPrank(proposer);
        token.claimFromEscrow(tokens);

        token.setApprovalForAll(address(dao), true);

        vm.expectRevert(abi.encodeWithSelector(NounsDAOLogicV1Fork.WaitingForTokensToClaimOrExpiration.selector));
        dao.quit(tokens);
    }

    function test_quit_givenFullClaim_works() public {
        vm.deal(timelock, 10 ether);
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 2;
        vm.prank(owner1);
        token.claimFromEscrow(tokens);

        vm.startPrank(proposer);
        tokens[0] = 1;
        token.claimFromEscrow(tokens);

        token.setApprovalForAll(address(dao), true);

        dao.quit(tokens);
        assertEq(proposer.balance, 5 ether);
    }

    function test_quit_givenTokensToClaimAndDelayedGovernanceExpires_works() public {
        vm.deal(timelock, 10 ether);
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 1;
        vm.startPrank(proposer);
        token.claimFromEscrow(tokens);

        vm.warp(dao.delayedGovernanceExpirationTimestamp());

        token.setApprovalForAll(address(dao), true);

        dao.quit(tokens);
        assertEq(proposer.balance, 10 ether);
    }
}

contract NounsDAOLogicV1Fork_Quit_Test is NounsDAOLogicV1ForkBase {
    address quitter = makeAddr('quitter');
    uint256[] quitterTokens;
    ERC20Mock token1;
    ERC20Mock token2;
    uint256 constant TOKEN1_BALANCE = 12345;
    uint256 constant TOKEN2_BALANCE = 8765;
    address[] tokens;

    function setUp() public override {
        super.setUp();

        // Set up ERC20s owned by the DAO
        mintERC20s();
        vm.prank(address(dao.timelock()));
        dao._setErc20TokensToIncludeInQuit(tokens);

        // Send ETH to the DAO
        vm.deal(address(dao.timelock()), 120 ether);

        mintNounsToQuitter();

        vm.prank(quitter);
        token.setApprovalForAll(address(dao), true);
    }

    function test_quit_tokensAreSentToTreasury() public {
        vm.prank(quitter);
        dao.quit(quitterTokens);

        assertEq(token.balanceOf(timelock), 2);
    }

    function test_quit_sendsProRataETHAndERC20s() public {
        assertEq(quitter.balance, 0);
        assertEq(token1.balanceOf(quitter), 0);
        assertEq(token2.balanceOf(quitter), 0);

        vm.prank(quitter);
        dao.quit(quitterTokens);

        assertEq(quitter.balance, 24 ether);
        assertEq(token1.balanceOf(quitter), (TOKEN1_BALANCE * 2) / 10);
        assertEq(token2.balanceOf(quitter), (TOKEN2_BALANCE * 2) / 10);
    }

    function test_quit_reentranceReverts() public {
        MaliciousForkDAOQuitter reentrancyQuitter = new MaliciousForkDAOQuitter(dao);
        transferQuitterTokens(address(reentrancyQuitter));

        vm.startPrank(address(reentrancyQuitter));
        token.setApprovalForAll(address(dao), true);

        vm.expectRevert(abi.encodeWithSelector(NounsDAOLogicV1Fork.QuitETHTransferFailed.selector));
        dao.quit(quitterTokens);
    }

    function test_quit_givenRecipientRejectsETH_reverts() public {
        ETHBlocker blocker = new ETHBlocker();
        transferQuitterTokens(address(blocker));

        vm.startPrank(address(blocker));
        token.setApprovalForAll(address(dao), true);

        vm.expectRevert(abi.encodeWithSelector(NounsDAOLogicV1Fork.QuitETHTransferFailed.selector));
        dao.quit(quitterTokens);
    }

    function test_quit_givenERC20SendFailure_reverts() public {
        token1.setFailNextTransfer(true);

        vm.prank(quitter);
        vm.expectRevert(abi.encodeWithSelector(NounsDAOLogicV1Fork.QuitERC20TransferFailed.selector));
        dao.quit(quitterTokens);
    }

    function transferQuitterTokens(address to) internal {
        uint256 quitterBalance = token.balanceOf(quitter);
        uint256[] memory tokenIds = new uint256[](quitterBalance);
        for (uint256 i = 0; i < quitterBalance; ++i) {
            tokenIds[i] = token.tokenOfOwnerByIndex(quitter, i);
        }
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            vm.prank(quitter);
            token.transferFrom(quitter, to, tokenIds[i]);
        }
        vm.roll(block.number + 1);
    }

    function mintERC20s() internal {
        token1 = new ERC20Mock();
        token1.mint(address(dao.timelock()), TOKEN1_BALANCE);
        token2 = new ERC20Mock();
        token2.mint(address(dao.timelock()), TOKEN2_BALANCE);
        tokens.push(address(token1));
        tokens.push(address(token2));
    }

    function mintNounsToQuitter() internal {
        address minter = token.minter();
        vm.startPrank(minter);
        while (token.totalSupply() < 10) {
            uint256 tokenId = token.mint();
            address to = proposer;
            if (tokenId > 7) {
                to = quitter;
                quitterTokens.push(tokenId);
            }
            token.transferFrom(token.minter(), to, tokenId);
        }
        vm.stopPrank();

        vm.roll(block.number + 1);

        assertEq(token.totalSupply(), 10);
        assertEq(token.balanceOf(quitter), 2);
    }
}

contract NounsDAOLogicV1Fork_AdjustedTotalSupply_Test is NounsDAOLogicV1ForkBase {
    uint256 constant TOTAL_MINTED = 20;
    uint256 constant MIN_ID_FOR_QUITTER = TOTAL_MINTED - ((2 * TOTAL_MINTED) / 10); // 20% of tokens go to quitter

    address quitter = makeAddr('quitter');
    uint256[] quitterTokens;

    function setUp() public override {
        super.setUp();

        address minter = token.minter();
        vm.startPrank(minter);
        while (token.totalSupply() < TOTAL_MINTED) {
            uint256 tokenId = token.mint();
            address to = proposer;
            if (tokenId >= MIN_ID_FOR_QUITTER) {
                to = quitter;
                quitterTokens.push(tokenId);
            }
            token.transferFrom(token.minter(), to, tokenId);
        }
        vm.stopPrank();

        vm.roll(block.number + 1);

        vm.prank(quitter);
        token.setApprovalForAll(address(dao), true);

        vm.startPrank(address(dao.timelock()));
        dao._setProposalThresholdBPS(1000);
        dao._setQuorumVotesBPS(2000);
        vm.stopPrank();
    }

    function test_proposalThreshold_usesAdjustedTotalSupply() public {
        assertEq(dao.proposalThreshold(), 2);

        vm.prank(quitter);
        dao.quit(quitterTokens);

        assertEq(dao.proposalThreshold(), 1);
    }

    function test_quorumVotes_usesAdjustedTotalSupply() public {
        assertEq(dao.quorumVotes(), 4);

        vm.prank(quitter);
        dao.quit(quitterTokens);

        assertEq(dao.quorumVotes(), 3);
    }

    function test_propose_setsThresholdAndQuorumUsingAdjustedTotalSupply() public {
        vm.prank(quitter);
        dao.quit(quitterTokens);
        uint256 proposalId = propose();

        assertEq(dao.proposals(proposalId).proposalThreshold, 1);
        assertEq(dao.proposals(proposalId).quorumVotes, 3);
    }
}

contract ETHBlocker {}
