// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 value) external;
    function transfer(address to, uint256 value) external;
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

contract VCGamersStaking {
    using SafeMath for uint256;
    IERC20 public stakeToken;
    IERC20 public rewardToken;
    IERC20 public token3;
    address payable public owner;
    uint256 public maxStakeableToken;
    uint256 public minimumStakeToken;
    uint256 public maxpoolbalance;
    uint256 public maxaccountbalance;
    uint256 public totalUnStakedToken;
    uint256 public totalStakedToken;
    uint256 public totalClaimedRewardToken;
    uint256 public totalStakers;
    uint256 public percentDivider;
    uint256 public totalFee;
    uint256[5] public Duration = [30 days, 60 days, 90 days, 180 days, 360 days];
    uint256[5] public Bonus = [12 , 30, 50, 110, 250];
    struct Stake {
        uint256 unstaketime;
        uint256 staketime;
        uint256 amount;
        uint256 rewardTokenAmount;
        uint256 reward;
        uint256 lastharvesttime;
        uint256 remainingreward;
        uint256 harvestreward;
        uint256 persecondreward;
        bool withdrawan;
        bool unstaked;
    }

    struct User {
        uint256 totalStakedTokenUser;
        uint256 totalUnstakedTokenUser;
        uint256 totalClaimedRewardTokenUser;
        uint256 stakeCount;
        bool alreadyExists;
    }

    mapping(address => User) public Stakers;
    mapping(uint256 => address) public StakersID;
    mapping(address => mapping(uint256 => Stake)) public stakersRecord;
    event STAKE(address Staker, uint256 amount);
    event HARVEST(address Staker, uint256 amount);
    event UNSTAKE(address Staker, uint256 amount);
    modifier onlyowner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    constructor(address payable _owner, address token1, address token2) {
        owner = _owner;
        stakeToken = IERC20(token1);
        rewardToken = IERC20(token2);
        totalFee = 0;
        maxStakeableToken = 20000000000000000000000;
        percentDivider = 1000;
        minimumStakeToken = 10000000000000000000;
        maxpoolbalance = 10000000000000000000000000;
        maxaccountbalance = 20000000000000000000000;
    }

    function stake(uint256 amount1, uint256 timeperiod) public {

        require(timeperiod >= 0 && timeperiod <= 4, "Invalid Time Period");
        require(amount1 >= minimumStakeToken, "stake min than minimum amount");
        require(amount1 <= maxStakeableToken, "stake more than maximum amount");

        //pool limiter
        require(totalStakedToken.add(amount1).sub(totalUnStakedToken) <= maxpoolbalance, "Pool Staking quota runs out");
        //account limiter
        require(Stakers[msg.sender].totalStakedTokenUser.add(amount1).sub(Stakers[msg.sender].totalUnstakedTokenUser) <= maxaccountbalance, "Account Staking quota runs out");

        uint256 VCGVAL = getPriceinUSD();
        uint256 amount = amount1.sub((amount1.mul(totalFee)).div(percentDivider));
        uint256 rewardtokenPrice = (amount.mul(VCGVAL)).div(1e18);
        
        
        if (!Stakers[msg.sender].alreadyExists) {
            Stakers[msg.sender].alreadyExists = true;
            StakersID[totalStakers] = msg.sender;
            totalStakers++;
        }

        stakeToken.transferFrom(msg.sender, address(this), amount1);
        uint256 index = Stakers[msg.sender].stakeCount;
        Stakers[msg.sender].totalStakedTokenUser = Stakers[msg.sender]
            .totalStakedTokenUser
            .add(amount);
        totalStakedToken = totalStakedToken.add(amount);
        stakersRecord[msg.sender][index].unstaketime = block.timestamp.add(
            Duration[timeperiod]
        );
        stakersRecord[msg.sender][index].staketime = block.timestamp;
        stakersRecord[msg.sender][index].amount = amount;
        stakersRecord[msg.sender][index].reward = rewardtokenPrice
            .mul(Bonus[timeperiod])
            .div(percentDivider);
        stakersRecord[msg.sender][index].persecondreward = stakersRecord[
            msg.sender
        ][index].reward.div(Duration[timeperiod]);
        stakersRecord[msg.sender][index].rewardTokenAmount = rewardtokenPrice;
        stakersRecord[msg.sender][index].lastharvesttime = 0;
        stakersRecord[msg.sender][index].remainingreward = stakersRecord[msg.sender][index].reward;
        stakersRecord[msg.sender][index].harvestreward = 0;
        Stakers[msg.sender].stakeCount++;
        emit STAKE(msg.sender, amount);
    }


    function unstake(uint256 index) public {
        require(!stakersRecord[msg.sender][index].unstaked, "already unstaked");
        require(
            stakersRecord[msg.sender][index].unstaketime < block.timestamp,
            "cannot unstake after before duration"
        );

        if(!stakersRecord[msg.sender][index].withdrawan){
            harvest(index);
        }
        stakersRecord[msg.sender][index].unstaked = true;

        stakeToken.transfer(
            msg.sender,
            stakersRecord[msg.sender][index].amount
        );
        
        totalUnStakedToken = totalUnStakedToken.add(
            stakersRecord[msg.sender][index].amount
        );
        Stakers[msg.sender].totalUnstakedTokenUser = Stakers[msg.sender]
            .totalUnstakedTokenUser
            .add(stakersRecord[msg.sender][index].amount);

        emit UNSTAKE(
            msg.sender,
            stakersRecord[msg.sender][index].amount
        );
    }

    function harvest(uint256 index) public {
        require(
            !stakersRecord[msg.sender][index].withdrawan,
            "already withdrawan"
        );
        require(!stakersRecord[msg.sender][index].unstaked, "already unstaked");
        uint256 rewardTillNow;
        uint256 commontimestamp;
        (rewardTillNow,commontimestamp) = realtimeRewardPerBlock(msg.sender , index);
        stakersRecord[msg.sender][index].lastharvesttime =  commontimestamp;
        rewardToken.transfer(
            msg.sender,
            rewardTillNow
        );
        totalClaimedRewardToken = totalClaimedRewardToken.add(
            rewardTillNow
        );
        stakersRecord[msg.sender][index].remainingreward = stakersRecord[msg.sender][index].remainingreward.sub(rewardTillNow);
        stakersRecord[msg.sender][index].harvestreward = stakersRecord[msg.sender][index].harvestreward.add(rewardTillNow);
        Stakers[msg.sender].totalClaimedRewardTokenUser = Stakers[msg.sender]
            .totalClaimedRewardTokenUser
            .add(rewardTillNow);
        if(stakersRecord[msg.sender][index].harvestreward == stakersRecord[msg.sender][index].reward){
            stakersRecord[msg.sender][index].withdrawan = true;

        }

        emit HARVEST(
            msg.sender,
            rewardTillNow
        );
    }

    function getPriceinUSD() public view returns (uint256){
        address BUSD_WBNB = 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16; //BUSD_WBNB pancake pool address
        IERC20 BUSDTOKEN = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // BUSD Token address
        IERC20 WBNBTOKEN = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); // WBNB Token address 
        uint256 BUSDSUPPLYINBUSD_WBNB = BUSDTOKEN.balanceOf(BUSD_WBNB);
        uint256 WBNBSUPPLYINBUSD_WBNB = WBNBTOKEN.balanceOf(BUSD_WBNB); 
        uint256 BNBPRICE = (BUSDSUPPLYINBUSD_WBNB.mul(1e18)).div(WBNBSUPPLYINBUSD_WBNB);
        address VCG_WBNB = 0xAe3691AdfEc53fE142ae0595F91811b1113d886f; // VCG_WBNB pancake pool address
        IERC20 VCGTOKEN = IERC20(0x1F36FB2D91d9951Cf58aE4c1956C0b77e224F1E9); // VCG Token address 
        uint256 WBNBSUPPLYINVCG_WBNB =(WBNBTOKEN.balanceOf(VCG_WBNB));
        uint256 VCGSUPPLYINVCG_WBNB = (VCGTOKEN.balanceOf(VCG_WBNB));
        uint256 VCGUSDVAL = (((WBNBSUPPLYINVCG_WBNB.mul(1e18)).div((VCGSUPPLYINVCG_WBNB))).mul(BNBPRICE)).div(1e18);
        return VCGUSDVAL;
    }

    function realtimeRewardPerBlock(address user, uint256 blockno) public view returns (uint256,uint256) {
        uint256 ret;
        uint256 commontimestamp;
            if (
                !stakersRecord[user][blockno].withdrawan &&
                !stakersRecord[user][blockno].unstaked
            ) {
                uint256 val;
                uint256 tempharvesttime = stakersRecord[user][blockno].lastharvesttime;
                commontimestamp = block.timestamp;
                if(tempharvesttime == 0){
                    tempharvesttime = stakersRecord[user][blockno].staketime;
                }
                val = commontimestamp - tempharvesttime;
                val = val.mul(stakersRecord[user][blockno].persecondreward);
                if (val < stakersRecord[user][blockno].remainingreward) {
                    ret += val;
                } else {
                    ret += stakersRecord[user][blockno].remainingreward;
                }
            }
        return (ret,commontimestamp);
    }

    function realtimeReward(address user) public view returns (uint256) {
        uint256 ret;
        for (uint256 i; i < Stakers[user].stakeCount; i++) {
            if (
                !stakersRecord[user][i].withdrawan &&
                !stakersRecord[user][i].unstaked
            ) {
                uint256 val;
                val = block.timestamp - stakersRecord[user][i].staketime;
                val = val.mul(stakersRecord[user][i].persecondreward);
                if (val < stakersRecord[user][i].reward) {
                    ret += val;
                } else {
                    ret += stakersRecord[user][i].reward;
                }
            }
        }
        return ret;
    }


    function SetStakeLimits(uint256 _min, uint256 _max) external onlyowner {
        minimumStakeToken = _min;
        maxStakeableToken = _max;
    }


    function SetPoolLimits(uint256 _amount) external onlyowner {
        maxpoolbalance = _amount;
    }

    function SetAccountLimits(uint256 _amount) external onlyowner {
        maxaccountbalance = _amount;
    }
    
    function SetTotalFees(uint256 _fee) external onlyowner {
        totalFee = _fee;
    }

    function SetStakeDuration(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth,
        uint256 fifth
    ) external onlyowner {
        Duration[0] = first;
        Duration[1] = second;
        Duration[2] = third;
        Duration[3] = fourth;
        Duration[4] = fifth;
    }

    function SetStakeBonus(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth,
        uint256 fifth
    ) external onlyowner {
        Bonus[0] = first;
        Bonus[1] = second;
        Bonus[2] = third;
        Bonus[3] = fourth;
        Bonus[4] = fifth;
    }


    function withdrawBNB() public onlyowner {
        uint256 balance = address(this).balance;
        require(balance > 0, "does not have any balance");
        payable(msg.sender).transfer(balance);
    }

    function initToken(address addr) public onlyowner{
        token3 = IERC20(addr);
    }
    function withdrawToken(uint256 amount) public onlyowner {
        token3.transfer(msg.sender
        , amount);
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}