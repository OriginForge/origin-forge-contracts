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
                    )
                    // json.property(
                    //     "attributes",
                    //     json.arrayOf(
                    //         Solarray.strings(
                    //             json.objectOf(
                    //                 Solarray.strings(
                    //                     json.property(
                    //                         "trait_type",
                    //                         "seed"
                    //                     ),
                    //                     json.property(
                    //                         "value",
                    //                         s.sbt[_tokenId].seed
                    //                     )
                    //                 )
                    //             ),
                    //             json.objectOf(
                    //                 Solarray.strings(
                    //                     json.property(
                    //                         "trait_type", 
                    //                         "baseEgg"
                    //                     ),
                    //                     json.property(
                    //                         "value",
                    //                         s.sbt[_tokenId].baseEgg
                    //                     )
                    //                 )
                    //             )
                    //         )
                    //     )
                    // )
                )
            )
        );

        return metaData;
    }

    function _generateSVG(uint _tokenId) public view returns (string memory) {
        return s.sbt[_tokenId].image;
    }

    function setSBT(uint _tokenId, string memory _image, string memory _seed, string memory _baseEgg) external {
        s.sbt[_tokenId].image = _image;
        s.sbt[_tokenId].seed = _seed;
        s.sbt[_tokenId].baseEgg = _baseEgg;
        // s.sbt[_tokenId].colorSet = _colorSet;
    }

    

}