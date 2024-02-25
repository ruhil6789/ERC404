import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
// import { Pb, Pb__factory } from "../typechain-types";
import { Pb__factory, Pb, ERC404, ERC404__factory, ERC721Reciever, ERC721Reciever__factory } from "../typechain-types";

describe("ERC404 testCases", () => {
    // let signer:SignerWithAddress;
    // let user1:SignerWithAddress;
    // let user2:SignerWithAddress;
    let pb: Pb
    let signer: any;
    let user1: any;
    let user2: any

    beforeEach(async () => {
        [signer, user1, user2] = await ethers.getSigners()
        console.log(await signer.getAddress(), user1.address, user2.address, "signer,user1,user2");


        pb = await new Pb__factory(signer).deploy(signer.address)
        console.log(await pb.getAddress(), "pbContract")

    })


    it("setNameSymbol", async () => {
        try {
            const result = await pb.connect(signer).setNameSymbol("PB", "0111");
            console.log("Result of setNameSymbol:", result);
        } catch (error) {
            console.error("Error:", error);
            // Handle error if necessary
        }
    });

    it("set token uri", async () => {
        try {
            const result = await pb.connect(signer).setTokenUri("The metadata often includes details like the name, description, and image of the token")
            console.log(result, "result")
        } catch (error) {
            console.error("Error:", error);

        }
    })


    it("token uri", async () => {
        try {

            const result = await pb.connect(user1).tokenURI(3)
            console.log(result, "result in the+++++++")
        } catch (error) {

        }
    })


    it("owner of", async () => {
        try {
            const result = await pb.connect(signer).ownerOf(3);
            
            
            console.log(result, "result in the owner of")
        } catch (error) {

        }
    })
})