const Bank = artifacts.require("Bank");
const BSCV = artifacts.require("BSCV");
const Client = artifacts.require("Client");
const Controller = artifacts.require("Controller");

module.exports = async function (deployer) {
  //await deployer.deploy(Bank);
  //await deployer.deploy(BSCV, Bank.address);
  // await deployer.deploy(
  //   Client,
  //   BSCV.address,
  //   "0x0000000000000000000000000000000000000000",
  //   70,
  //   100,
  //   Bank.address
  // );
  await deployer.deploy(
    Controller,
    "0x37fBA930Ce4C4D75Ae902b9222046783c5660bda",
    Client.address,
    BSCV.address
  );
};
