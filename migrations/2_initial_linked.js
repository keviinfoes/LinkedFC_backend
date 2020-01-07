var LinkedPROXY = artifacts.require("LinkedPROXY");
var LinkedTKN = artifacts.require("LinkedTKN");
var LinkedCOL = artifacts.require("LinkedCOL");
var LinkedCUS = artifacts.require("LinkedCUS");
var LinkedORCL = artifacts.require("LinkedORCL");
var LinkedTAX = artifacts.require("LinkedTAX");
var LinkedDEFCON = artifacts.require("LinkedDEFCON");
var LinkedEXC = artifacts.require("LinkedEXC");

module.exports = function(deployer) {
  deployer.deploy(LinkedPROXY);
  deployer.deploy(LinkedTKN);
  deployer.deploy(LinkedCOL);
  deployer.deploy(LinkedCUS);
  deployer.deploy(LinkedORCL);
  deployer.deploy(LinkedTAX);
  deployer.deploy(LinkedDEFCON);
  deployer.deploy(LinkedEXC);
};
