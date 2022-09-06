// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Question.sol";

contract QAContract is QuestionContract {
    using Counters for Counters.Counter;

    Counters.Counter private _answerIdCounter;
    Counters.Counter private _refIdCounter;

    // structure of answers
    struct Answer {
        uint256 tokenId;
        address payable sender;
        string aText;
        uint256 refId;
    }

    struct Ref {
        string qacType;
        uint256 qacId;
        address qacSender;
    }

    //This mapping maps tokenId to token info and is helpful when retrieving details about a tokenId
    mapping(uint256 => Answer) aIdToAnswer;
    mapping(uint256 => Ref) refIdToRef;

    /**
     * @dev function about answering
     */
    function setAnswer(
        uint256 _tokenId,
        string memory _aText,
        string memory _qacType,
        uint256 _qacId,
        address _qacSender
    ) public isValidToken(_tokenId) {
        uint256 aId = _answerIdCounter.current();
        _answerIdCounter.increment();

        uint256 _refId = _setRef(_qacType, _qacId, _qacSender);
        
        Answer memory _answer = Answer(
            _tokenId,
            payable(msg.sender),
            _aText,
            _refId
        );
        aIdToAnswer[aId] = _answer;
    }

    function _setRef(
        string memory _qacType,
        uint256 _qacId,
        address _qacSender
    ) internal returns (uint256) {
        uint256 _refId = _refIdCounter.current();
        _refIdCounter.increment();
        refIdToRef[_refId] = Ref(_qacType, _qacId, _qacSender);
        return _refId;
    }

    modifier isValidToken(uint256 _tokenId) {
        // console.log(block.timestamp);
        require(
            block.timestamp < tokenIdToQ[_tokenId].expires,
            "This Quesction expired."
        );
        _;
    }

    function getAnswerForAnswerId(uint256 _aId)
        public
        view
        returns (Answer memory)
    {
        return aIdToAnswer[_aId];
    }

    // function getAnswersForTokenId(uint256 _tokenId)
    //     public
    //     view
    //     returns (Answer[] memory)
    // {
    //     uint256 totalAnswerCount = _answerIdCounter.current();
    //     uint256 answerCount = 0;
    //     uint256 currentIndex = 0;

    //     for (uint256 i = 0; i < totalAnswerCount; i++) {
    //         if (aIdToAnswer[i].tokenId == _tokenId) {
    //             answerCount += 1;
    //         }
    //     }

    //     Answer[] memory answers = new Answer[](answerCount);
    //     for (uint256 i = 0; i < totalAnswerCount; i++) {
    //         if (aIdToAnswer[i].tokenId == _tokenId) {
    //             answers[currentIndex] = aIdToAnswer[i];
    //             currentIndex += 1;
    //         }
    //     }
    //     return answers;
    // }

    function getAllAnswers() public view returns (Answer[] memory) {
        uint256 totalAnswerCount = _answerIdCounter.current();
        uint256 currentIndex = 0;

        Answer[] memory answers = new Answer[](totalAnswerCount);
        for (uint256 i = 0; i < totalAnswerCount; i++) {
            answers[currentIndex] = aIdToAnswer[i];
            currentIndex += 1;
        }
        return answers;
    }
}
