import { ethers, upgrades } from "hardhat";

// 0x1EDE12711979DfDB44cB2dCee3269C9CFBb25911
// async function main() {
//   const Token = await ethers.getContractFactory("OriginForge");


//   const token = await upgrades.deployProxy(Token, [
//     "0x12920802d981ac6F5A33dA158738756BDb3B1f9B",
//     "0x999999999939ba65abb254339eec0b2a0dac80e9", // gcklay
//   ]);

//   await token.waitForDeployment();

//   console.log("token deployed to:", await token.getAddress());

// }

async function main() {
  // 0x1EDE12711979DfDB44cB2dCee3269C9CFBb25911
  const Token = await ethers.getContractFactory("OriginForge");

  const token = await upgrades.upgradeProxy(
    "0x1EDE12711979DfDB44cB2dCee3269C9CFBb25911",
    Token,
    {}
  );

  await token.waitForDeployment();

  console.log("token deployed to:", await token.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});