// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "hardhat/console.sol";

contract CoAnswer is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;
    Counters.Counter private _answerIdCounter;
    Counters.Counter private _commentIdCounter;

    uint256 MINT_PRICE = 0.001 ether;
    uint256 COMMENT_PRICE = 0.0001 ether;

    // structure of question nft
    struct Question {
        address payable owner;
        string question;
    }

    // structure of answers
    struct Answer {
        uint256 tokenId;
        address payable sender;
        string answerText;
    }

    //structure or comments
    struct Comment {
        uint256 tokenId;
        uint256 answerId;
        address payable sender;
        string answerText;
    }

    //This mapping maps tokenId to token info and is helpful when retrieving details about a tokenId
    mapping(uint256 => Question) tokenIdToQuestion;
    mapping(uint256 => Answer) answerIdToAnswer;
    mapping(uint256 => Comment) commentIdToComment;

    constructor() ERC721("CoAnswer", "CAS") {}

    /**
     * function about mint QuestionNft
     */
    function safeMint(address to, string memory question) public payable {
        require(msg.value == MINT_PRICE);
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        tokenIdToQuestion[tokenId] = Question(payable(msg.sender), question);

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    function getQuestionForId(uint256 tokenId)
        public
        view
        returns (Question memory)
    {
        return tokenIdToQuestion[tokenId];
    }

    function generateImage(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        string memory question = getQuestionForId(tokenId).question;
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Question: ",
            question,
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getTokenURI(uint256 _tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Question #',
            _tokenId.toString(),
            '",',
            '"description": "question description",',
            '"image": "',
            generateImage(_tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    /**
     * @dev function about answering
     */
    function setAnswer(uint256 _tokenId, string memory _answerText) public {
        uint256 answerId = _answerIdCounter.current();
        _answerIdCounter.increment();
        Answer memory _answer = Answer(
            _tokenId,
            payable(msg.sender),
            _answerText
        );
        answerIdToAnswer[answerId] = _answer;
    }

    function getAnswerForAnswerId(uint256 _answerId)
        public
        view
        returns (Answer memory)
    {
        return answerIdToAnswer[_answerId];
    }

    function getAnswersForTokenId(uint256 _tokenId)
        public
        view
        returns (Answer[] memory)
    {
        uint256 totalAnswerCount = _answerIdCounter.current();
        uint256 answerCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalAnswerCount; i++) {
            if (answerIdToAnswer[i].tokenId == _tokenId) {
                answerCount += 1;
            }
        }

        Answer[] memory answers = new Answer[](answerCount);
        for (uint256 i = 0; i < totalAnswerCount; i++) {
            if (answerIdToAnswer[i].tokenId == _tokenId) {
                answers[currentIndex] = answerIdToAnswer[i];
                currentIndex += 1;
            }
        }
        return answers;
    }

    function getAllAnswers() public view returns (Answer[] memory) {
        uint256 totalAnswerCount = _answerIdCounter.current();
        uint256 currentIndex = 0;

        Answer[] memory answers = new Answer[](totalAnswerCount);
        for (uint256 i = 0; i < totalAnswerCount; i++) {
            answers[currentIndex] = answerIdToAnswer[i];
            currentIndex += 1;
        }
        return answers;
    }

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

    /**
     * @dev helper function
     */
    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
