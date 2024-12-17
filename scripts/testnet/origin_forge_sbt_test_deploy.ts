import { ethers, upgrades } from "hardhat";

// 0x7010318eC478490c756216b5dAD8496Cc22B8D35
// async function main() {
//   const Token = await ethers.getContractFactory("OriginForgeSBT");


//   const token = await upgrades.deployProxy(Token, [
//     "0x12920802d981ac6F5A33dA158738756BDb3B1f9B",
//   ]);

//   await token.waitForDeployment();

//   console.log("token deployed to:", await token.getAddress());

// }




async function main() {
  // 0x7010318eC478490c756216b5dAD8496Cc22B8D35
  const Token = await ethers.getContractFactory("OriginForgeSBT");

  const token = await upgrades.upgradeProxy(
    "0x7010318eC478490c756216b5dAD8496Cc22B8D35",
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