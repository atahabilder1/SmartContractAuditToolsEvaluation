pragma solidity 0.4.26;
import "./MocBTCToUSDOracle.sol";

// This contract is only for test purposes
// https://github.com/money-on-chain/Amphiraos-Oracle/blob/master/contracts/medianizer/medianizer.sol
contract MoCMedianizerMock is Medianizer {
	uint256 public value;
	bool public has;

	function peek() external view returns (bytes32, bool) {
		return (bytes32(value), has);
	}

	function setValue(uint256 _value) public {
		value = _value;
	}

	function setHas(bool _has) public {
		has = _has;
	}
}
