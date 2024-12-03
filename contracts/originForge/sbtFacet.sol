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
        string memory svgString = string(abi.encodePacked(
            '<svg width="500" height="500" viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">',
            '<defs>',
            '<linearGradient id="borderGradient" x1="0%" y1="0%" x2="100%" y2="100%">',
            '<stop offset="0%" style="stop-color:#9B4DCA;stop-opacity:1">',
            '<animate attributeName="stop-color" values="#9B4DCA;#7B2FBE;#6A1B9A;#9B4DCA" dur="8s" repeatCount="indefinite"/>',
            '</stop>',
            '<stop offset="50%" style="stop-color:#7B2FBE;stop-opacity:1">',
            '<animate attributeName="stop-color" values="#7B2FBE;#6A1B9A;#9B4DCA;#7B2FBE" dur="8s" repeatCount="indefinite"/>',
            '</stop>',
            '<stop offset="100%" style="stop-color:#6A1B9A;stop-opacity:1">',
            '<animate attributeName="stop-color" values="#6A1B9A;#9B4DCA;#7B2FBE;#6A1B9A" dur="8s" repeatCount="indefinite"/>',
            '</stop>',
            '</linearGradient>',
            '<filter id="magicGlow">',
            '<feGaussianBlur stdDeviation="4" result="coloredBlur"/>',
            '<feFlood flood-color="#E0B0FF" flood-opacity="0.3" result="glowColor"/>',
            '<feComposite in="glowColor" in2="coloredBlur" operator="in" result="softGlow"/>',
            '<feMerge>',
            '<feMergeNode in="softGlow"/>',
            '<feMergeNode in="SourceGraphic"/>',
            '</feMerge>',
            '</filter>',
            '<animate id="mysticalBreath" attributeName="transform" type="scale" values="1;1.02;1;1.02;1" dur="5s" repeatCount="indefinite" calcMode="spline" keySplines="0.4 0 0.2 1; 0.4 0 0.2 1; 0.4 0 0.2 1; 0.4 0 0.2 1"/>',
            '</defs>',
            '<rect width="100%" height="100%" fill="url(#borderGradient)" opacity="0.1"/>',
            '<rect width="98%" height="98%" x="1%" y="1%" fill="none" stroke="url(#borderGradient)" stroke-width="8" filter="url(#magicGlow)"/>',
            '<g transform="translate(250,250)">',
            '<g transform-origin="0 0">',
            '<image id="egg" x="-200" y="-200" width="400" height="400" href="',
            _renderCharacter(_tokenId),
            '" filter="url(#magicGlow)">',
            '<animateTransform attributeName="transform" type="scale" values="1;1.03;1;1.03;1" dur="5s" repeatCount="indefinite" calcMode="spline" keySplines="0.4 0 0.2 1; 0.4 0 0.2 1; 0.4 0 0.2 1; 0.4 0 0.2 1"/>',
            '</image>',
            '</g>',
            '</g>',
            '<image x="370" y="20" width="50" height="50" href="',
            'data:image/gif;base64,R0lGODlhEAAQAPMAAAAAAABEZgZXfw9smReUpSDFuHLuz/b43////wAAAAAAAAAAAAAAAAAAAAAAAAAAACH/C05FVFNDQVBFMi4wAwEAAAAh+QQBFAAAACwAAAAAEAAQAAADNAi63P5wjdjEmRSIcgyGFnFwnxMMxnEQQnSKBesOhFEULfSOsk6PuFktlvPZiq4DkrLMQBIAIfkEARQAAAAsAAAAABAAEAAABDoQyEmrvXiOXMXZHCAUhwFiHnGQSBYMxnEQLfaqBe0OhFEUtcttpbPxVsBdLxcUwgqCECBwiEpF11AEACH5BAEUAAAALAAAAAAQABAAAAQ3EMhJq714jlzF2RwgFIeBcB5xFMiJBYNxHG0Gq6x73UZuD7jaC7gS7oA94zEZAgQOgqYkKuVEAAAh+QQBFAAAACwAAAAAEAAQAAAEMBDISau9eKJckeeS4CEDJxzjUWLBMBJC1r4x63pFfc0eLN+I3I/GCYx0mRFIs1xGAAAh+QQBFAAAACwAAAAAEAAQAAAENBDISau9eI5c0dkcgHgGiAnjUXxZkB6E0KZFPCNGUciY69W8i0+1u+VsmVEumDwwOc8QJgIAIfkEARQAAAAsAAAAABAAEAAABDoQyEmrvXiOXMXZHCAUhwFiyEEc5Gkhg3GoQgavBVGjA2EUhd3lxtLZeqzg0ZcTXgIxZShwcHKsIUwEACH5BAEUAAAALAAAAAAQABAAAAM0CLrc/nCN2MSZFIhyDIYWcXCfEwzGcRBCdIoF6w6EURQt9I6yTo+4WS2W89mKrgOSssxAEgAh+QQBFAAAACwAAAAAEAAQAAADNAi63P5wjdjEmRSIcgyGFnFwnxMMxnEQQnSKBesOhFEULfSOsk6PuFktlvPZiq4DkrLMQBIAOw==',
            '" />',
            '<image x="400" y="20" width="50" height="50" href="',
            'data:image/gif;base64,R0lGODlhEAAQAPMAAAAAAHIAFpEAHaUMK8wXKeU4Lv9uZf+2sv///wAAAAAAAAAAAAAAAAAAAAAAAAAAACH/C05FVFNDQVBFMi4wAwEAAAAh+QQBFAAAACwAAAAAEAAQAAADNAi63P5wjdjEmRSIcgyGFnFwnxMMxnEQQnSKBesOhFEULfSOsk6PuFktlvPZiq4DkrLMQBIAIfkEARQAAAAsAAAAABAAEAAABDoQyEmrvXiOXMXZHCAUhwFiHnGQSBYMxnEQLfaqBe0OhFEUtcttpbPxVsBdLxcUwgqCECBwiEpF11AEACH5BAEUAAAALAAAAAAQABAAAAQ3EMhJq714jlzF2RwgFIeBcB5xFMiJBYNxHG0Gq6x73UZuD7jaC7gS7oA94zEZAgQOgqYkKuVEAAAh+QQBFAAAACwAAAAAEAAQAAAEMBDISau9eKJckeeS4CEDJxzjUWLBMBJC1r4x63pFfc0eLN+I3I/GCYx0mRFIs1xGAAAh+QQBFAAAACwAAAAAEAAQAAAENBDISau9eI5c0dkcgHgGiAnjUXxZkB6E0KZFPCNGUciY69W8i0+1u+VsmVEumDwwOc8QJgIAIfkEARQAAAAsAAAAABAAEAAABDoQyEmrvXiOXMXZHCAUhwFiyEEc5Gkhg3GoQgavBVGjA2EUhd3lxtLZeqzg0ZcTXgIxZShwcHKsIUwEACH5BAEUAAAALAAAAAAQABAAAAM0CLrc/nCN2MSZFIhyDIYWcXCfEwzGcRBCdIoF6w6EURQt9I6yTo+4WS2W89mKrgOSssxAEgAh+QQBFAAAACwAAAAAEAAQAAADNAi63P5wjdjEmRSIcgyGFnFwnxMMxnEQQnSKBesOhFEULfSOsk6PuFktlvPZiq4DkrLMQBIAOw==',
            '" />',
            '<image x="430" y="20" width="50" height="50" href="',
            'data:image/gif;base64,R0lGODlhEAAQAPMAAAAAAAtROA5mOBJ/NBuZFxyyMh7lfn//zf///wAAAAAAAAAAAAAAAAAAAAAAAAAAACH/C05FVFNDQVBFMi4wAwEAAAAh+QQBFAAAACwAAAAAEAAQAAADNAi63P5wjdjEmRSIcgyGFnFwnxMMxnEQQnSKBesOhFEULfSOsk6PuFktlvPZiq4DkrLMQBIAIfkEARQAAAAsAAAAABAAEAAABDoQyEmrvXiOXMXZHCAUhwFiHnGQSBYMxnEQLfaqBe0OhFEUtcttpbPxVsBdLxcUwgqCECBwiEpF11AEACH5BAEUAAAALAAAAAAQABAAAAQ3EMhJq714jlzF2RwgFIeBcB5xFMiJBYNxHG0Gq6x73UZuD7jaC7gS7oA94zEZAgQOgqYkKuVEAAAh+QQBFAAAACwAAAAAEAAQAAAEMBDISau9eKJckeeS4CEDJxzjUWLBMBJC1r4x63pFfc0eLN+I3I/GCYx0mRFIs1xGAAAh+QQBFAAAACwAAAAAEAAQAAAENBDISau9eI5c0dkcgHgGiAnjUXxZkB6E0KZFPCNGUciY69W8i0+1u+VsmVEumDwwOc8QJgIAIfkEARQAAAAsAAAAABAAEAAABDoQyEmrvXiOXMXZHCAUhwFiyEEc5Gkhg3GoQgavBVGjA2EUhd3lxtLZeqzg0ZcTXgIxZShwcHKsIUwEACH5BAEUAAAALAAAAAAQABAAAAM0CLrc/nCN2MSZFIhyDIYWcXCfEwzGcRBCdIoF6w6EURQt9I6yTo+4WS2W89mKrgOSssxAEgAh+QQBFAAAACwAAAAAEAAQAAADNAi63P5wjdjEmRSIcgyGFnFwnxMMxnEQQnSKBesOhFEULfSOsk6PuFktlvPZiq4DkrLMQBIAOw==',
            '" />',
            '</svg>'
        ));

        return string(abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(bytes(svgString))
        ));
    }

    function _renderColorSetText(uint _tokenId) internal view returns (string memory) {
        string memory colorSetText = "";
        for(uint i = 0; i < s.sbt[_tokenId].colorSet.length; i++) {
            colorSetText = string(abi.encodePacked(
                colorSetText,
                '<text x="350" y="',
                LibString.toString(480 + (i * 20)),
                '" font-family="Arial" font-size="14" fill="white">',
                'Color ', LibString.toString(i+1), ': ',
                s.sbt[_tokenId].colorSet[i],
                '</text>'
            ));
        }
        return colorSetText;
    }

    function _renderCharacter(uint _tokenId) internal view returns (string memory) {
        return s.sbt[_tokenId].image;
    }

    function setSBT(uint _tokenId, string memory _image, string memory _seed, string memory _baseEgg, string[] memory _colorSet) external  {
        s.sbt[_tokenId].image = _image;
        s.sbt[_tokenId].seed = _seed;
        s.sbt[_tokenId].baseEgg = _baseEgg;
        s.sbt[_tokenId].colorSet = _colorSet;

        
    }

    function mintSBT(address _to, string memory _userId) external {
        IERC721 nft = IERC721(s.contractNames["nft"]);
        nft.safeMint(_to, s.users[_userId].userSBTId);
    }

    
    

}