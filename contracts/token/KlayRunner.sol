pragma solidity ^0.5.0;


import "./KIP17/KIP17Full.sol";
import "./KIP17/KIP17Mintable.sol";
import "./KIP17/KIP17MetadataMintable.sol";
import "./KIP17/KIP17Burnable.sol";
import "./KIP17/KIP17Pausable.sol";
import "../ownership/Ownable.sol";


contract KlayRunner is KIP17Full, KIP17Mintable, KIP17MetadataMintable, KIP17Burnable, KIP17Pausable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter public tokenCounter;
    
    
    bool public isPublicSaleActive = true;
    bool public isPreSaleActive = true;
    string baseURI;
    uint256 public maxSupply;
    uint256 public price;
    uint256 public maxPurchase;
    mapping(address => uint256) private _whiteList; 
    mapping(address => uint256) private _tokensMintedByAddressAtPresale; 
    
    
    event Klaytn17Burn(address _to, uint256 tokenId);


    constructor (
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _maxSupply,
        uint256 _price,
        uint256 _maxPurchase
    )
        KIP17Mintable()
        KIP17MetadataMintable()
        KIP17Burnable()
        KIP17Pausable()
        KIP17Full(_name, _symbol) public {
        baseURI = _baseURI;
        maxSupply = _maxSupply;
        price = _price;
        maxPurchase = _maxPurchase;
    }
    
    

    function startPublicSale() public onlyOwner {
        isPublicSaleActive = true;
    }


    function pausePublicSale() public onlyOwner {
        isPublicSaleActive = false;
    }
    
    
    function startPreSale() public onlyOwner {
        isPreSaleActive = true;
    }


    function pausePreSale() public onlyOwner {
        isPreSaleActive = false;
    }
    
    
    function setWhiteList(address[] calldata addresses, uint256 numAllowedToMint) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _whiteList[addresses[i]] = numAllowedToMint;
        }
    }


    function preSaleMint(uint256 numberOfTokens) external payable whenNotPaused {
        require(isPreSaleActive, "Pre-sale minting is not active.");
        require(numberOfTokens <= maxPurchase, "Exceeds maximum purchase."); 
        require(tokenCounter.current().add(numberOfTokens) <= maxSupply, "Exceeds maximum supply.");
        require(price * numberOfTokens <= msg.value, "Klayn value sent is not enough.");
        require(_tokensMintedByAddressAtPresale[msg.sender] + numberOfTokens <= _whiteList[msg.sender], "Exceeds whitelist quota."); 
        mints(msg.sender, numberOfTokens);
        _tokensMintedByAddressAtPresale[msg.sender] = _tokensMintedByAddressAtPresale[msg.sender] + numberOfTokens;

    }
    

    function publicSaleMint(uint256 numberOfTokens) external payable whenNotPaused {
        require(isPublicSaleActive, "Public sale minting is not active.");
        require(numberOfTokens <= maxPurchase, "Exceeds maximum purchase."); 
        require(tokenCounter.current().add(numberOfTokens) <= maxSupply, "Exceeds maximum supply.");
        require(price * numberOfTokens <= msg.value, "Klayn value sent is not enough.");
        mints(msg.sender, numberOfTokens);

        
    }


    function mints (
        address _to,
        uint256 _amount
    ) private {
        for (uint i = 0; i < _amount; i++) {
            require(tokenCounter.current() < maxSupply, 'Exceeds maximum supply.');

            uint256 newTokenId = tokenCounter.current();
            _mint(_to, newTokenId);
            _setTokenURI(newTokenId, string(abi.encodePacked(baseURI, uint2str(newTokenId))));
            tokenCounter.increment();
        }
    }


    // onlyOwner

    function ownerMint(uint256 numberOfTokens) external payable onlyOwner {
        require(numberOfTokens <= maxPurchase, "Too many requested."); 
        require(tokenCounter.current().add(numberOfTokens) <= maxSupply, "Exceeds maximum supply.");
        mints(msg.sender, numberOfTokens);
    }
    
    
    function setPrice (uint256 _price) public onlyOwner {
        price = _price;
    }
    

    function setBaseURI (string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }


    function setMaxPurchase (uint256 _maxPurchase) public onlyOwner {
        maxPurchase = _maxPurchase;
    }


    function withdraw (address payable _to) public onlyOwner {
        _to.transfer(address(this).balance);
    }


    // Util

    function uint2str (
        uint _i
    ) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    // Public view
    
	function tokensOfOwner(address _owner) external view returns(uint256[] memory ownerTokens) {
		uint256 tokenCount = balanceOf(_owner);

		if (tokenCount == 0) {
			// Return an empty array
			return new uint256[](0);
		} else {
			uint256[] memory result = new uint256[](tokenCount);
			uint256 totalKeys = totalSupply();
			uint256 resultIndex = 0;

			// We count on the fact that all tokens have IDs starting at 1 and increasing
			// sequentially up to the totalSupply count.
			uint256 tokenId;

			for (tokenId = 1; tokenId <= totalKeys; tokenId++) {
				if (ownerOf(tokenId) == _owner) {
					result[resultIndex] = tokenId;
					resultIndex++;
				}
			}

			return result;
		}
	}
}