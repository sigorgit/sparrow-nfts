pragma solidity ^0.5.6;

import "./klaytn-contracts/token/KIP37/KIP37.sol";
import "./klaytn-contracts/token/KIP37/KIP37Burnable.sol";
import "./klaytn-contracts/token/KIP37/KIP37Pausable.sol";
import "./klaytn-contracts/ownership/Ownable.sol";
import "./klaytn-contracts/math/SafeMath.sol";

// 참새 NFT
// 떡방앗간 참새들이 NFT를 만들 수 있는 스마트 계약
contract SparrowNFTs is Ownable, KIP37, KIP37Burnable, KIP37Pausable {
    using SafeMath for uint256;

    uint256 public current = 0;
    mapping(uint256 => address) public minters;
    mapping(uint256 => string) public extnames;
    mapping(uint256 => string) public titles;
    mapping(uint256 => string) public descriptions;

    constructor() public KIP37("https://api.ricecakemill.com/sparrow/nft/{id}.json") {}

    function uri(uint256 _tokenId) external view returns (string memory) {
        uint256 tokenId = _tokenId;
        require(minters[tokenId] != address(0), "KIP37: URI query for nonexistent token");
        
        if (tokenId == 0) {
            return "https://api.ricecakemill.com/sparrow/nft/0.json";
        }

        string memory baseURI = "https://api.ricecakemill.com/sparrow/nft/";
        string memory idstr;
        
        uint256 temp = tokenId;
        uint256 digits;
        while (temp != 0) {
            digits += 1;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (tokenId != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(tokenId % 10)));
            tokenId /= 10;
        }
        idstr = string(buffer);

        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, idstr)) : "";
    }
    
    function mint(string calldata extname, string calldata title, string calldata description, uint256 amount) external {
        _mint(msg.sender, current, amount, "");
        minters[current] = msg.sender;
        extnames[current] = extname;
        titles[current] = title;
        descriptions[current] = description;
        current = current.add(1);
    }

    function mintMore(uint256 id, uint256 amount) external {
        require(minters[id] == msg.sender);
        _mint(msg.sender, id, amount, "");
    }

    function changeInfo(uint256 id, string calldata extname, string calldata title, string calldata description) external {
        require(minters[id] == msg.sender);
        extnames[id] = extname;
        titles[id] = title;
        descriptions[id] = description;
    }
}
