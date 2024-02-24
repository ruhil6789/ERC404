import { ethers } from "hardhat";

async function main(){
   const [signer]=await ethers.getSigners()
   console.log("signer Address",await signer.getAddress())
   
   
   const token = await  ethers.getContractFactory("Pb");

    const tokenDeploy= await token.deploy(signer.address)
    console.log("pb token address:",await tokenDeploy.getAddress());

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});