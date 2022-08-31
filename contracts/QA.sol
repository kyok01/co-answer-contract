// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Question.sol";

contract QAContract is QuestionContract {
    using Counters for Counters.Counter;

    Counters.Counter private _answerIdCounter;

    // structure of answers
    struct Answer {
        uint256 tokenId;
        address payable sender;
        string answerText;
    }

    //This mapping maps tokenId to token info and is helpful when retrieving details about a tokenId
    mapping(uint256 => Answer) answerIdToAnswer;

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
}
