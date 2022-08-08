import hre from "hardhat";
// 0xB2eE2C6785Abc20C5D4cF37cDC96F577b77d04c0 // verify된 컨트랙
// 내가 보니까 배포하고 난 후에는 아애 컨트랙을 수정하면 안되나봐
// 그러니까 배포한 다음에 바로 verify해야할 듯
const main = async () => {
  const contractAddress = "0xfeB47E7DD5F6aA56D97c770369412cd2F3561aF0";
  await hre.run("verify:verify", {
    address: contractAddress,
  });
};
main();
