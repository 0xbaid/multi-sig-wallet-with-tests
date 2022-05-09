// SPDX-License-Identifier: Uindentified
pragma solidity ^0.8.0;

contract multiSigWallet {
    address[] public approvers;
    uint256 public quorum; //Min No. of approvals required to process transaction
    struct Transfer {
        uint256 id;
        uint256 amount;
        address payable to;
        uint256 approvals;
        bool sent;
    }
    Transfer[] public transfers;
    mapping(address => mapping(uint256 => bool)) public approvals; //who is approving which transactions by ids

    constructor(address[] memory _approvers, uint256 _quorum) {
        approvers = _approvers;
        quorum = _quorum;
    }

    //Since the approvers variable will have own get function but it will return single address, to get all addresses
    //we create our own get function
    function getApprovers() external view returns (address[] memory) {
        return approvers;
    }

    //create transfer function
    function createTransfer(uint256 _amount, address payable _to)
        external
        onlyApprover
    {
        transfers.push(Transfer(transfers.length, _amount, _to, 0, false));
    }

    //Since the transfers variable will have own get function but it will return single element, to get all elements
    //we create our own get function
    //if returning struct from function gets error add "pragma experimental ABIEncoderV2", because of outdated compiler
    function getTransfers() external view returns (Transfer[] memory) {
        return transfers;
    }

    function approveTransfer(uint256 _id) external onlyApprover {
        require(transfers[_id].sent == false, "transfer has already sent");
        require(
            approvals[msg.sender][_id] == false,
            "cannot approve transfer twice"
        );
        approvals[msg.sender][_id] == true;
        transfers[_id].approvals++;

        if (transfers[_id].approvals >= quorum) {
            transfers[_id].sent == true;
            address payable to = transfers[_id].to;
            uint256 amount = transfers[_id].amount;
            to.transfer(amount);
        }
    }

    //receive ether
    receive() external payable {} //to send ether to smart contract address

    modifier onlyApprover() {
        bool allowed = false;
        for (uint256 i = 0; i < approvers.length; i++) {
            if (approvers[i] == msg.sender) {
                allowed = true;
            }
        }
        require(allowed == true, "only approver allowed");
        _;
    }
}
