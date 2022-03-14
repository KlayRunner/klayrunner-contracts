const HDWalletProvider = require("truffle-hdwallet-provider-klaytn");

const privateKey = "0xd0ebcc336f6e90cb41e9bc48cdf5521f12bbf6b95e65a1f8f23e486b5492b5bc" // Enter your private key;

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    testnet: {
      provider: () => new HDWalletProvider(privateKey, "https://api.baobab.klaytn.net:8651"),
      network_id: '1001', //Klaytn baobab testnet's network id
      gas: '100000000',
      gasPrice: null, 
      networkCheckTimeout: 30000
    },
    mainnet: {
      provider: () => new HDWalletProvider(privateKey, "https://your.cypress.en.url:8651"),
      network_id: '8217', //Klaytn mainnet's network id
      gas: '8500000',
      gasPrice: null
    }
  },
  compilers: {
    solc: {
      version: "0.5.6"
    }
  }
};