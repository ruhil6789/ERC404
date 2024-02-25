//SPDX-License-Identifier:MIT
pragma solidity 0.8.20;

abstract contract Ownable {
    event  transferownerShip(address indexed user, address indexed newOwner);
    error Unauthorized();
    error InvalidOwner();
    address public owner;

    modifier onlyOwner()  virtual{
        if(msg.sender == owner){
             require(msg.sender == owner,"only owner ");
        }else{
            require(msg.sender !=owner);
              revert Unauthorized();

        }
        _;
    }
    constructor(address _owner){

      if(_owner== address(0))   revert InvalidOwner();

      owner=_owner;
      emit  transferownerShip(address(0),_owner);
    }


    function ownershipTransfer(address _owner) public virtual onlyOwner(){
        if(_owner ==address(0))  revert InvalidOwner();


        owner =_owner;

        emit transferownerShip(msg.sender, _owner);
    }



    function  revokeOwnership() public virtual onlyOwner{
        owner = address(0);
        emit transferownerShip(msg.sender, address(0));
    }

}

abstract contract ERC721Reciever{
    function onERC721Recieved(address, address,uint256 , bytes calldata) external virtual  returns(bytes4){
        return ERC721Reciever.onERC721Recieved.selector;
    }
}

/// @dev combining features of ERC20 and ERC721
///   decimals are 18 
///  NFTs are spent on ERC20 functions in a FILO queue


abstract contract ERC404 is Ownable{
    event  transferERC20(address indexed from,address indexed to,uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );
    event approvalERC721(
         address indexed owner,
         address indexed spender,
         uint256 indexed id
    );
   event approvalForAll(
    address indexed owner, 
    address indexed operator,
    bool approved);


    // error
    error NotFound();
    error AlreadyExists();
    error InvalidRecipient();
    error InvalidSender();
    error UnsafeReciepient();

     string public name;
     string public symbol;
     uint8 public immutable decimals;
     uint256  public immutable totalSupply;
//  increased everyTime  
     uint256 public minted; 

 mapping(address =>uint256) public balanceOf;
 mapping(address=>mapping(address=>uint256)) public allowance;
//   approval for single
 mapping(uint256=>address) public getApproved;
//  approval for all
 mapping(address=>mapping(address=>bool))public isApprovalForAll;

mapping(uint256 =>address) internal _ownerOf;
mapping(address=>uint256[]) internal _idOwned;
// track the id
mapping(uint256 =>uint256) internal _ownerIndex; 
//  addresss to be whitelisted for minting and burning
mapping(address =>bool) public whitelist;

constructor (
 string memory _name,
 string memory _symbol,
 uint8 _decimals,
 uint256 _totalSupply,
 address _owner
) Ownable(_owner){
  name=_name;
  symbol=_symbol;
  decimals=_decimals;
  totalSupply=_totalSupply  * (10 ** decimals);

}

function setWhiteListAddresses(address target,bool addressState) public onlyOwner{
    whitelist[target]=addressState;
}

function ownerOf(uint256 id) public view virtual returns(address owner){
    owner = _ownerOf[id];
    if(owner==address(0)){
        revert NotFound();
    }
}
 function approve(
        address spender,
        uint256 amountOrId
    ) public virtual returns (bool) {
        if (amountOrId <= minted && amountOrId > 0) {
            address owner = _ownerOf[amountOrId];

            if (msg.sender != owner && !isApprovalForAll[owner][msg.sender]) {
                revert Unauthorized();
            }

            getApproved[amountOrId] = spender;

            emit Approval(owner, spender, amountOrId);
        } else {
            allowance[msg.sender][spender] = amountOrId;

            emit Approval(msg.sender, spender, amountOrId);
        }

        return true;
    }

//  approval
function setApprovalForAll(address operator,bool approved) public virtual {
    isApprovalForAll[msg.sender][operator]=approved;
    emit approvalForAll(msg.sender,operator,approved);
}

function transferFrom(address from ,address to ,uint256 amountOrId) public virtual {
    if(amountOrId <= minted){
        if(from != _ownerOf[amountOrId]){
            revert InvalidSender();
        }
        if(to ==address(0)){
            revert InvalidRecipient();
        }

        if(msg.sender !=from && !isApprovalForAll[from][msg.sender] && msg.sender != getApproved[amountOrId]){
            revert Unauthorized();
        }

        balanceOf[from] -=_getUnits();
        unchecked {
            balanceOf[to] += _getUnits();
        }
        _ownerOf[amountOrId]=to;
        delete getApproved[amountOrId];

      uint256 updatedId = _idOwned[from][_idOwned[from].length - 1];
      _idOwned[from][_ownerIndex[amountOrId]]= updatedId;
     _idOwned[from].pop();
     _ownerIndex[updatedId] = _ownerIndex[amountOrId];
     _idOwned[to].push(amountOrId);
     _ownerIndex[amountOrId]= _idOwned[to].length-1;

     emit Transfer(from, to, amountOrId);
     emit transferERC20(from, to, _getUnits());
    }else{
    uint256 allowed = allowance[from][msg.sender];

       if (allowed != type(uint256).max)
                allowance[from][msg.sender] = allowed - amountOrId;

            _transfer(from, to, amountOrId);
    }
}

function transfer(address to , uint256 amount) public virtual returns(bool){
    return _transfer(msg.sender, to, amount);
}


function safeTransferFrom(address from , address to , uint256 id) public virtual {
    transferFrom(from, to, id);

    if(
        to.code.length !=0 && 
        ERC721Reciever(to).onERC721Recieved(msg.sender,from,id,"") != ERC721Reciever.onERC721Recieved.selector
    ){
     revert UnsafeReciepient();
    }
}

function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 unit = _getUnits();
        uint256 balanceBeforeSender = balanceOf[from];
        uint256 balanceBeforeReceiver = balanceOf[to];

        balanceOf[from] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        // Skip burn for certain addresses to save gas
        if (!whitelist[from]) {
            uint256 tokens_to_burn = (balanceBeforeSender / unit) -
                (balanceOf[from] / unit);
            for (uint256 i = 0; i < tokens_to_burn; i++) {
                _burn(from);
            }
        }

        // Skip minting for certain addresses to save gas
        if (!whitelist[to]) {
            uint256 tokens_to_mint = (balanceOf[to] / unit) -
                (balanceBeforeReceiver / unit);
            for (uint256 i = 0; i < tokens_to_mint; i++) {
                _mint(to);
            }
        }

        emit transferERC20(from, to, amount);
        return true;
    }


function _mint(address to ) internal  virtual{
    if(to ==address(0)){
        revert InvalidRecipient();
    }
    unchecked {
        minted ++;
    }

    uint256 id = minted;
    if(_ownerOf[id]!=address(0)){
     revert AlreadyExists();

    }
    _ownerOf[id]=to;
    _idOwned[to].push(id);
    _ownerIndex[id]=_idOwned[to].length-1;
    emit Transfer(address(0),to,id);
}



function _burn(address from) internal virtual {
    if(from ==address(0)){
        revert InvalidSender();
    }

    uint256 id = _idOwned[from][_idOwned[from].length-1];
    _idOwned[from].pop();
    delete _ownerIndex[id];
    delete _ownerOf[id];
    delete getApproved[id];
    emit Transfer(from, address(0), id);
}

function _getUnits() internal view returns(uint256){
    return 10 ** decimals;
}

  function _setMetadata(string memory _name,string  memory _symbol) internal {
    name=_name;
    symbol=_symbol;
  }

}