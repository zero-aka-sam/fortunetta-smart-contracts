const BSCV = artifacts.require("BSCV");
const Client = artifacts.require("Client");
const Controller = artifacts.require("Controller");

module.exports = function (deployer) {
  deployer.deploy(BSCV, "0x0000000000000000000000000000000000000000");
};

module.exports = function (deployer) {
  deployer.deploy(
    Client,
    BSCV.address,
    "0x0000000000000000000000000000000000000000",
    10,
    60
  );
};

module.exports = function (deployer) {
  deployer.deploy(
    Controller,
    "0x6f2b3Ccd825F8182505E209AcE7b4576369E54AB",
    Client.address,
    BSCV.address
  );
};
