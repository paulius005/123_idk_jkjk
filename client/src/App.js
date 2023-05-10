import React, { useState, useEffect } from 'react';

const Example = () => {
  const [message, setMessage] = useState('');

  useEffect(() => {
    fetch('/example/message')
      .then((response) => response.json())
      .then((data) => setMessage(data.message))
      .catch((error) => console.error('Error:', error));
  }, []);

  return (
    <div>
      <h1>Example Component1</h1>
      <p>{message}</p>
    </div>
  );
};

export default Example;
