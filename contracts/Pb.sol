// SDPX-License-Identifier:MIT;
import "./ERC404.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
pragma solidity 0.8.20;

contract Pb is ERC404 {
     string public dataUri;
     string public baseTokenUri;

constructor(address _owner) ERC404("Pb","0111",18,100000,_owner){
     balanceOf[_owner]= 10000 * 10 ** 18;

}


function setDataUri(string memory _dataURI) public onlyOwner{
     dataUri= _dataURI;
}

function setTokenUri(string memory _tokenURI) public onlyOwner{
     baseTokenUri=_tokenURI;
}
    function setNameSymbol(
        string memory _name,
        string memory _symbol
    ) public onlyOwner {
        _setMetadata(_name, _symbol);
    }

function tokenURI(uint256 id) public view  returns(string memory){
     if(bytes(baseTokenUri).length >0){
          return string.concat(baseTokenUri,Strings.toString(id));
     }else{
     uint8 seed = uint8(bytes1(keccak256(abi.encodePacked(id))));
            string memory image;
            string memory color;

            if (seed <= 100) {
                image = "1.gif";
                color = "Yellow";
            } else if (seed <= 160) {
                image = "2.gif";
                color = "Green";
            } else if (seed <= 210) {
                image = "3.gif";
                color = "Black";
            } else if (seed <= 240) {
                image = "4.gif";
                color = "Pink";
            } else if (seed <= 255) {
                image = "5.gif";
                color = "Red";
            }


         string memory jsonPreImage = string.concat(
                string.concat(
                    string.concat('{"name": "0111 #', Strings.toString(id)),
                    '","description":"A collection of 10,0000.","external_url":"https://www.google.com","image":"'
                ),
                string.concat(dataUri, image)
            );


           string memory jsonPostImage = string.concat(
                '","attributes":[{"trait_type":"Color","value":"',
                color
            );
            string memory jsonPostTraits = '"}]}';

              return
                string.concat(
                    "data:application/json;utf8,",
                    string.concat(
                        string.concat(jsonPreImage, jsonPostImage),
                        jsonPostTraits
                    )
                );
     }
   }
}
