import {
  Center, Container, Text
} from '@mantine/core';
import classes from './AppFooter.module.css';


function AppFooter() {
  return (
    <div className={classes.footer}>
      <Container className={classes.footerInner}>
        <Center>
          <Text className={classes.text}>
            CYOA Story Generator
          </Text>
        </Center>
      </Container>
    </div>
  );
}

export default AppFooter;
