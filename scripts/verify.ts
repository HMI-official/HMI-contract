import hre from "hardhat";

const main = async () => {
  const contractAddress = "0xC3441afD07A9266D8441F15A7c43d9667B287879";
  await hre.run("verify:verify", {
    address: contractAddress,
  });
};
main();
