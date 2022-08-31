// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./QA.sol";

contract QACContract is QAContract {
    using Counters for Counters.Counter;

    Counters.Counter private _commentIdCounter;

    uint256 COMMENT_PRICE = 0.0001 ether;

    //structure or comments
    struct Comment {
        uint256 tokenId;
        uint256 answerId;
        address payable sender;
        string answerText;
    }

    //This mapping maps tokenId to token info and is helpful when retrieving details about a tokenId
    mapping(uint256 => Comment) commentIdToComment;

    /**
     * @dev function about comment
     */
    function setComment(uint256 _answerId, string memory _commentText)
        public
        payable
    {
        require(msg.value == COMMENT_PRICE);
        uint256 commentId = _commentIdCounter.current();
        _commentIdCounter.increment();
        uint256 tokenId = answerIdToAnswer[_answerId].tokenId;

        Comment memory _comment = Comment(
            tokenId,
            _answerId,
            payable(msg.sender),
            _commentText
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

    function getCommentsForAnswerId(uint256 _answerId)
        public
        view
        returns (Comment[] memory)
    {
        uint256 totalCommentCount = _commentIdCounter.current();
        uint256 currentIndex = 0;
        uint256 commentCount = 0;

        for (uint256 i = 0; i < totalCommentCount; i++) {
            if (commentIdToComment[i].answerId == _answerId) {
                commentCount += 1;
            }
        }

        Comment[] memory comments = new Comment[](commentCount);
        for (uint256 i = 0; i < totalCommentCount; i++) {
            if (commentIdToComment[i].answerId == _answerId) {
                comments[currentIndex] = commentIdToComment[i];
                currentIndex += 1;
            }
        }
        return comments;
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
}
