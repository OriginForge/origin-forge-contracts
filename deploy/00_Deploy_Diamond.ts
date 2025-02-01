import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import fs from "fs";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, deployments, getChainId } = hre;

  const { diamond } = deployments;

  const { deployer, diamondAdmin } = await getNamedAccounts();

  await diamond.deploy("origin-forge-diamond-V2", {
    from: deployer,
    owner: diamondAdmin,
    facets: ["ofFacet"],
  });

  if ((await getChainId()) == "1001") {
    const testnetABI = JSON.parse(
      fs.readFileSync(
        "./deployments/kaia_testnet/origin-forge-diamond-V2.json",
        "utf8"
      )
    ).abi;
    return fs.writeFileSync(
      "./origin-forge-diamond-V2-TEST.abi",
      JSON.stringify(testnetABI)
    );
  }
  const mainnetABI = JSON.parse(
    fs.readFileSync(
      "./deployments/kaia_mainnet/origin-forge-diamond-V2.json",
      "utf8"
    )
  ).abi;

  return fs.writeFileSync(
    "./origin-forge-diamond-V2-MAIN.abi",
    JSON.stringify(mainnetABI)
  );
};

export default func;
