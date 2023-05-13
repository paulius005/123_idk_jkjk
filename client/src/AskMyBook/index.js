import { Button, View, TextArea, Text, Image } from 'reshaped';

import React, { useState, useRef } from 'react';
import axios from 'axios';
import AnimatedText from '../AnimatedText';

import './index.css';

const App = () => {
  const textAreaRef = useRef(null);

  const [answer, setAnswer] = useState('');
  const [question, setQuestion] = useState(
    'What is this coding exercise about?'
  );
  const [animatedTextDone, setAnimatedTextDone] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  function generateQuestion() {
    const options = [
      'What is this coding exercise about?',
      'How long will it take?',
      'Should I write unit tests for this exercise?',
      'What is the best way to start this exercise?',
    ];
    const randomArrIndex = ~~(Math.random() * options.length);

    return options[randomArrIndex];
  }

  async function askQuestion(generate = false) {
    try {
      let questionToSend = question;

      if (generate) {
        questionToSend = generateQuestion();

        setQuestion(questionToSend);
      }

      setIsLoading(true);
      const response = await axios.post('/questions/ask', {
        question: questionToSend,
      });
      setIsLoading(false);
      const { data } = response;

      setAnswer(data.answer);
    } catch (error) {
      setIsLoading(false);
      console.error('Error fetching data:', error);
    }
  }

  return (
    <View
      maxWidth='70ch'
      direction='column'
      align='center'
      justify='start'
      gap={6}
      className='mainView'
      padding={4}
    >
      <Image
        className='bookImage'
        src='https://imagedelivery.net/YtcfQnb_m3yN9uzdhMII_A/0980e8bf-715f-4e2a-cb90-ecece879ad00/public'
        height='200px'
      ></Image>
      <Text variant='title-2'>Ask My Book</Text>
      <Text variant='featured-3' color='neutral-faded'>
        This is an experiment in using AI to make my book's content more
        accessible. Ask a question and AI will answer it in real-time:
      </Text>
      <TextArea
        className='mainTextArea'
        attributes={{ ref: textAreaRef }}
        placeholder='What is this coding exercise about?'
        onChange={({ event, name, value }) => {
          setQuestion(value);
          setAnswer('');
        }}
        value={question}
      ></TextArea>
      {!answer && (
        <View direction='row' align='center' justify='center' gap={4}>
          <Button
            color='primary'
            size='xlarge'
            onClick={() => askQuestion(false)}
            disabled={isLoading}
          >
            {isLoading ? 'Asking...' : 'Ask question'}
          </Button>
          <Button
            size='xlarge'
            disabled={isLoading}
            onClick={() => {
              askQuestion(true);
            }}
          >
            I'm feeling lucky
          </Button>
        </View>
      )}
      {answer && (
        <Text className='answerText' variant='featured-3' color='neutral-faded'>
          <b>Answer:</b>
          <AnimatedText text={answer} setDone={setAnimatedTextDone} />
        </Text>
      )}
      {answer && animatedTextDone && (
        <View direction='row' align='start' justify='start' width='100%'>
          <Button
            color='primary'
            size='xlarge'
            onClick={() => {
              textAreaRef.current.children[0].focus();

              // move cursor to end of text area
              textAreaRef.current.children[0].selectionStart =
                textAreaRef.current.children[0].value.length;
              setAnswer('');
            }}
          >
            Ask another question
          </Button>
        </View>
      )}
    </View>
  );
};

export default App;
