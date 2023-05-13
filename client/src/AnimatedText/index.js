import React, { useState, useEffect } from 'react';

const AnimatedText = ({ text, setDone }) => {
  const [visibleText, setVisibleText] = useState('');
  const [interval, setInterval] = useState(300);

  function randomInteger(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  useEffect(() => {
    let timer;

    if (visibleText.length < text.length) {
      setDone(false);
      setInterval(randomInteger(30, 70));

      timer = setTimeout(() => {
        setVisibleText(text.slice(0, visibleText.length + 1));
      }, interval);
    } else {
      setDone(true);
    }

    return () => clearTimeout(timer);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [visibleText, text]);

  return <span>{visibleText}</span>;
};

export default AnimatedText;
