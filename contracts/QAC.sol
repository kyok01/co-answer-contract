// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./QA.sol";

contract QACContract is QAContract {
    using Counters for Counters.Counter;

    Counters.Counter private _commentIdCounter;
    Counters.Counter internal _repIdCounter;

    uint256 COMMENT_BOTTOM_PRICE = 0.0001 ether;

    //structure or comments
    struct Comment {
        uint256 tokenId;
        uint256 answerId;
        address payable sender;
        string answerText;
        uint256 price;
    }

    struct Reply {
        uint256 cId;
        bool repHasWithdrawn;
    }

    //This mapping maps tokenId to token info and is helpful when retrieving details about a tokenId
    mapping(uint256 => Comment) commentIdToComment;
    mapping(uint256 => Reply) repIdToReply;

    /**
     * @dev function about comment
     */
    function setComment(uint256 _answerId, string memory _commentText, uint256 _price)
        public
        payable
        isValidToken(aIdToAnswer[_answerId].tokenId)
    {
        if (msg.sender != ownerOf(aIdToAnswer[_answerId].tokenId)) {
            require(msg.value >= COMMENT_BOTTOM_PRICE);
            require(msg.value == _price);
        }
        uint256 commentId = _commentIdCounter.current();
        _commentIdCounter.increment();
        uint256 tokenId = aIdToAnswer[_answerId].tokenId;

        Comment memory _comment = Comment(
            tokenId,
            _answerId,
            payable(msg.sender),
            _commentText,
            _price
        );
        commentIdToComment[commentId] = _comment;
    }

    function getCommentForCommentId(uint256 _commentId)
        public
        view
        returns (Comment memory)
    {
        return commentIdToComment[_commentId];
    }

    function getCommentsForTokenId(uint256 _tokenId)
        public
        view
        returns (Comment[] memory)
    {
        uint256 totalCommentCount = _commentIdCounter.current();
        uint256 currentIndex = 0;
        uint256 commentCount = 0;

        for (uint256 i = 0; i < totalCommentCount; i++) {
            if (commentIdToComment[i].tokenId == _tokenId) {
                commentCount += 1;
            }
        }

        Comment[] memory comments = new Comment[](commentCount);
        for (uint256 i = 0; i < totalCommentCount; i++) {
            if (commentIdToComment[i].tokenId == _tokenId) {
                comments[currentIndex] = commentIdToComment[i];
                currentIndex += 1;
            }
        }
        return comments;
    }

    function getAllComments() public view returns (Comment[] memory) {
        uint256 totalCommentCount = _commentIdCounter.current();
        uint256 currentIndex = 0;

        Comment[] memory comments = new Comment[](totalCommentCount);
        for (uint256 i = 0; i < totalCommentCount; i++) {
            comments[currentIndex] = commentIdToComment[i];
            currentIndex += 1;
        }
        return comments;
    }

    /**
     * @dev function about reply
     */
    function setRep(uint256 _cId)
        public
        isValidToken(aIdToAnswer[commentIdToComment[_cId].answerId].tokenId)
    {
        if (msg.sender != ownerOf(aIdToAnswer[commentIdToComment[_cId].answerId].tokenId)) {
            require(msg.sender == aIdToAnswer[commentIdToComment[_cId].answerId].sender);
        }
        uint256 repId = _repIdCounter.current();
        _repIdCounter.increment();

        Reply memory _reply = Reply(
            _cId,
            false
        );
        repIdToReply[repId] = _reply;
    }

    function getReplyForRepId(uint256 _repId)
        public
        view
        returns (Reply memory)
    {
        return repIdToReply[_repId];
    }

    function getAllReplies() public view returns (Reply[] memory) {
        uint256 totalRepCount = _repIdCounter.current();
        uint256 currentIndex = 0;

        Reply[] memory replies = new Reply[](totalRepCount);
        for (uint256 i = 0; i < totalRepCount; i++) {
            replies[currentIndex] = repIdToReply[i];
            currentIndex += 1;
        }
        return replies;
    }
}
