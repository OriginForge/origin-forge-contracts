import { ethers, upgrades } from "hardhat";

// export const SBT_ADDRESS = "0xf4BFfF05f9444d394D084D9516a35c54A7B50222";

// async function main() {
//   const Token = await ethers.getContractFactory("OriginForgeSBT");


//   const token = await upgrades.deployProxy(Token, [
//     "0x12920802d981ac6F5A33dA158738756BDb3B1f9B",
//   ]);

//   await token.waitForDeployment();

//   console.log("token deployed to:", await token.getAddress());

// }




async function main() {
  // 0xf4BFfF05f9444d394D084D9516a35c54A7B50222
  const Token = await ethers.getContractFactory("OriginForgeSBT");

  const token = await upgrades.upgradeProxy(
    "0xf4BFfF05f9444d394D084D9516a35c54A7B50222",
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