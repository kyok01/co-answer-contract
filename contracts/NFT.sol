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
    struct Props {
        address payable owner;
        string question;
    }

    // structure of answers
    struct Answer {
        uint256 tokenId;
        uint256 answerId;
        address payable sender;
        string answerText;
    }

    struct Answers {
        Answer[] answers;
    }

    // structure or comments
    struct Comment {
        uint256 tokenId;
        uint256 answerId;
        uint256 commentId;
        address payable sender;
        string answerText;
    }

    struct Comments {
        Comment[] comments;
    }

    //This mapping maps tokenId to token info and is helpful when retrieving details about a tokenId
    mapping(uint256 => Props) idToProps;
    mapping(uint256 => Answers) idToAnswers;
    mapping(uint256 => uint256) answerToId;
    mapping(uint256 => Comments) answerToComments;

    constructor() ERC721("CoAnswer", "CAS") {}

    /**
     * function about mint QuestionNft
     */
    function safeMint(address to, string memory question) public payable {
        require(msg.value == MINT_PRICE);
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        idToProps[tokenId] = Props(payable(msg.sender), question);

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    function getPropsForId(uint256 tokenId) public view returns (Props memory) {
        return idToProps[tokenId];
    }

    function generateImage(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        string memory question = getPropsForId(tokenId).question;
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

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Question #',
            tokenId.toString(),
            '",',
            '"description": "question description",',
            '"image": "',
            generateImage(tokenId),
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
    function setAnswer(uint256 tokenId, string memory answerText) public {
        uint256 answerId = _answerIdCounter.current();
        _answerIdCounter.increment();
        Answer memory _answer = Answer(
            tokenId,
            answerId,
            payable(msg.sender),
            answerText
        );
        idToAnswers[tokenId].answers.push(_answer);
        answerToId[answerId] = tokenId;
    }

    function getAnswers(uint256 tokenId) public view returns (Answer[] memory) {
        console.log(
            "sender",
            idToAnswers[tokenId].answers[0].sender,
            idToAnswers[tokenId].answers[1].sender
        );
        return idToAnswers[tokenId].answers;
    }

    /**
     * @dev function about comment
     */
    function setComment(uint256 answerId, string memory commentText) public payable{
        require(msg.value == COMMENT_PRICE);
        uint256 commentId = _commentIdCounter.current();
        _commentIdCounter.increment();
        uint256 tokenId = answerToId[answerId];

        Comment memory _comment = Comment(
            tokenId,
            answerId,
            commentId,
            payable(msg.sender),
            commentText
        );
        answerToComments[answerId].comments.push(_comment);
    }

    function getComments(uint256 answerId)
        public
        view
        returns (Comment[] memory)
    {
        console.log(
            "sender",
            answerToComments[answerId].comments[0].sender,
            answerToComments[answerId].comments[1].sender
        );
        return answerToComments[answerId].comments;
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
