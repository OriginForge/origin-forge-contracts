import { ethers, upgrades } from "hardhat";



// async function main() {
//   const Token = await ethers.getContractFactory("OriginForgeItem");


//   const token = await upgrades.deployProxy(Token, [
//     "0x12920802d981ac6F5A33dA158738756BDb3B1f9B",
//   ]);

//   await token.waitForDeployment();

//   console.log("token deployed to:", await token.getAddress());

// }




async function main() {
  // 0x9e7ef3bE724c1F6d26342E4fD0C025a658654381
  const Token = await ethers.getContractFactory("OriginForgeItem");

  const token = await upgrades.upgradeProxy(
    "0x9e7ef3bE724c1F6d26342E4fD0C025a658654381",
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