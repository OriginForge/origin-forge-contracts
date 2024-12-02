// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {modifiersFacet} from "../shared/utils/modifiersFacet.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {IERC721} from "../shared/interfaces/IERC721.sol";
import {svg} from "../shared/libraries/svg.sol";
import {Metadata, DisplayType} from "../shared/libraries/Metadata.sol";
import {json} from "../shared/libraries/json.sol";
import {Solarray} from "../shared/libraries/Solarray.sol";
import {LibString} from "solady/src/utils/LibString.sol";

contract sbtFacet is modifiersFacet {
    using svg for *;
    using Metadata for *;


    // delegate EOA mint
    function nft_mint(address _to, uint _tokenId) external {
        // _mint(_to, _tokenId);
    }

    function nft_getUri(uint _tokenId) external view returns (string memory) {
        string[] memory staticTraits = getAttributes(_tokenId);
        string[] memory dynamicTraits = getDynamicAttributes(_tokenId);
        string[] memory combined = new string[](staticTraits.length + dynamicTraits.length);


        for(uint256 i = 0; i < staticTraits.length; i++){
            combined[i] = staticTraits[i];
        }
        for(uint256 i = 0; i < dynamicTraits.length; i++){
            combined[staticTraits.length + i] = dynamicTraits[i];
        }

        string memory metaData = Metadata.base64JsonDataURI(
            json.objectOf(
                Solarray.strings(
                    json.property(
                        "name",
                        string.concat(
                            "Test SBT #",
                            LibString.toString(_tokenId)
                        )
                    ),
                    json.property(
                        "description",
                        "the Test SBT is a unique SBT that represents a user in the Origin Forge."
                    ),
                    json.property(
                        "image",
                        _generateSVG(_tokenId)
                    ),
                    json.rawProperty("attributes", json.arrayOf(combined))
                )
            )
        );

        return metaData;
    }

    function getAttributes(uint _tokenId) internal view returns (string[] memory){
        return Solarray.strings(
            Metadata.attribute("seed", s.sbt[_tokenId].seed, DisplayType.String),
            Metadata.attribute("baseEgg", s.sbt[_tokenId].baseEgg, DisplayType.Number)
        );
    }

    function getDynamicAttributes(uint _tokenId) internal view returns (string[] memory){
        string[] memory dynamicTraits = new string[](s.sbt[_tokenId].colorSet.length);
        for(uint256 i = 0; i < s.sbt[_tokenId].colorSet.length; i++){
            dynamicTraits[i] = Metadata.attribute("colorSet", s.sbt[_tokenId].colorSet[i], DisplayType.String);
        }
        return dynamicTraits;
    }

    

    function _generateSVG(uint _tokenId) public view returns (string memory) {
        return s.sbt[_tokenId].image;
    }

    function setSBT(uint _tokenId, string memory _image, string memory _seed, string memory _baseEgg, string[] memory _colorSet) external {
        s.sbt[_tokenId].image = _image;
        s.sbt[_tokenId].seed = _seed;
        s.sbt[_tokenId].baseEgg = _baseEgg;
        s.sbt[_tokenId].colorSet = _colorSet;
    }

    
    

}