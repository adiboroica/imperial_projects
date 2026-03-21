import '../style/base.css';
import Button from 'react-bootstrap/Button';
import React from 'react';
import { Link } from 'react-router-dom';
import Container from 'react-bootstrap/Container';

const WelcomeView = () => {
  return (
    <Container
      id="welcome-section"
      className="wrapper d-flex flex-column justify-content-center
        align-items-center">
      <div id="welcome-title">
        <h1><span className="fancy">Choose Your Own Adventure</span> Story Generator</h1>
        <p>
          Quickly generate a complete, editable gamebook with a single prompt.
        </p>
      </div>
      <Link to='/generator'>
        <Button variant="light" size="lg">
          Get Started
        </Button>
      </Link>
    </Container>
  );
}

export default WelcomeView;
