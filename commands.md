Remove-Item -Recurse -Force node_modules

remixd -s . --remix-ide https://remix.ethereum.org

    "@nomiclabs/hardhat-ethers": "^2.0.6",
    "@nomiclabs/hardhat-etherscan": "^3.0.4",
    "@nomiclabs/hardhat-waffle": "^2.0.3",
    "@openzeppelin/contracts": "^4.6.0",
    "@typechain/hardhat": "^6.0.0",
    "dotenv": "^16.0.1",
    "erc721a": "^4.0.0",
    "hardhat": "^2.9.7",
    "hardhat-gas-reporter": "^1.0.8",
    "solidity-coverage": "^0.7.21"

npm install --save-dev ts-node
npx hardhat compile
npx hardhat run scripts/deployContract.ts --network rinkeby
npx hardhat run scripts/deployContract_copy.ts --network rinkeby
npx hardhat run scripts/verifyContract.ts --network rinkeby
remixd -s . --remix-ide https://remix.ethereum.org
