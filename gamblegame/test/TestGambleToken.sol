pragma solidity ^0.4.16;

import 'truffle/Assert.sol';
import 'truffle/DeployedAddresses.sol';
import '../contracts/GambleToken.sol';

contract TestGambleToken {
    
    GambleToken game = GambleToken(DeployedAddresses.GambleToken());

    function testCheckBonus() public {
        bool bonusValid = game.checkBonus();
        bool expected = true;
        Assert.equal(bonusValid, expected, "Bonus should be true.");
    }

    // function testUserCanAdoptPet() public {
    //     uint returnedId = adoption.adopt(8);
    //     uint expected = 8;
    //     Assert.equal(returnedId, expected, "Aoption of pet Id 8 should be recorded.");
    // }


}



