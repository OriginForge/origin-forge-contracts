import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import fs from "fs";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, deployments, getChainId } = hre;

  const { diamond } = deployments;

  const { deployer, diamondAdmin } = await getNamedAccounts();

  await diamond.deploy("elementa-diamond-V1", {
    from: deployer,
    owner: diamondAdmin,
    facets: ["adminFacet", "userFacet", "nftFacet", "botMiniGameFacet"],
  });

  if ((await getChainId()) == "1001") {
    const testnetABI = JSON.parse(
      fs.readFileSync(
        "./deployments/kaia_testnet/elementa-diamond-V1.json",
        "utf8"
      )
    ).abi;
    return fs.writeFileSync(
      "./elementa-diamond-V1-TEST.abi",
      JSON.stringify(testnetABI)
    );
  }
  const mainnetABI = JSON.parse(
    fs.readFileSync(
      "./deployments/kaia_mainnet/elementa-diamond-V1.json",
      "utf8"
    )
  ).abi;

  return fs.writeFileSync(
    "./elementa-diamond-V1-MAIN.abi",
    JSON.stringify(mainnetABI)
  );
};

export default func;
