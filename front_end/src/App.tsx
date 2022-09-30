import React from 'react';
import { DAppProvider, Goerli, Config } from '@usedapp/core';
import {Header} from "./components/Header"
import {Main} from "./components/Main"
import { getDefaultProvider } from 'ethers';
import { Container } from "@material-ui/core";

function App() {
  const config: Config = {
    readOnlyUrls: {
      [Goerli.chainId]: getDefaultProvider('goerli'),
    },
  }

  return (
    <DAppProvider config={config}>
      <Header/>
      <Container maxWidth="md">
        <Main/>
      </Container>
    </DAppProvider>
  );
}

export default App;
