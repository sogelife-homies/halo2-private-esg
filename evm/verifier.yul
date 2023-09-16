
        object "plonk_verifier" {
            code {
                function allocate(size) -> ptr {
                    ptr := mload(0x40)
                    if eq(ptr, 0) { ptr := 0x60 }
                    mstore(0x40, add(ptr, size))
                }
                let size := datasize("Runtime")
                let offset := allocate(size)
                datacopy(offset, dataoffset("Runtime"), size)
                return(offset, size)
            }
            object "Runtime" {
                code {
                    let success:bool := true
                    let f_p := 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
                    let f_q := 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001
                    function validate_ec_point(x, y) -> valid:bool {
                        {
                            let x_lt_p:bool := lt(x, 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47)
                            let y_lt_p:bool := lt(y, 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47)
                            valid := and(x_lt_p, y_lt_p)
                        }
                        {
                            let y_square := mulmod(y, y, 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47)
                            let x_square := mulmod(x, x, 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47)
                            let x_cube := mulmod(x_square, x, 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47)
                            let x_cube_plus_3 := addmod(x_cube, 3, 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47)
                            let is_affine:bool := eq(x_cube_plus_3, y_square)
                            valid := and(valid, is_affine)
                        }
                    }
                    mstore(0x20, mod(calldataload(0x0), f_q))
mstore(0x40, mod(calldataload(0x20), f_q))
mstore(0x0, 3378033142087240671593067145207522850278999096980429962890425795123137158235)

        {
            let x := calldataload(0x40)
            mstore(0x60, x)
            let y := calldataload(0x60)
            mstore(0x80, y)
            success := and(validate_ec_point(x, y), success)
        }
mstore(0xa0, keccak256(0x0, 160))
{
            let hash := mload(0xa0)
            mstore(0xc0, mod(hash, f_q))
            mstore(0xe0, hash)
        }
mstore8(256, 1)
mstore(0x100, keccak256(0xe0, 33))
{
            let hash := mload(0x100)
            mstore(0x120, mod(hash, f_q))
            mstore(0x140, hash)
        }
mstore8(352, 1)
mstore(0x160, keccak256(0x140, 33))
{
            let hash := mload(0x160)
            mstore(0x180, mod(hash, f_q))
            mstore(0x1a0, hash)
        }

        {
            let x := calldataload(0x80)
            mstore(0x1c0, x)
            let y := calldataload(0xa0)
            mstore(0x1e0, y)
            success := and(validate_ec_point(x, y), success)
        }

        {
            let x := calldataload(0xc0)
            mstore(0x200, x)
            let y := calldataload(0xe0)
            mstore(0x220, y)
            success := and(validate_ec_point(x, y), success)
        }

        {
            let x := calldataload(0x100)
            mstore(0x240, x)
            let y := calldataload(0x120)
            mstore(0x260, y)
            success := and(validate_ec_point(x, y), success)
        }

        {
            let x := calldataload(0x140)
            mstore(0x280, x)
            let y := calldataload(0x160)
            mstore(0x2a0, y)
            success := and(validate_ec_point(x, y), success)
        }
mstore(0x2c0, keccak256(0x1a0, 288))
{
            let hash := mload(0x2c0)
            mstore(0x2e0, mod(hash, f_q))
            mstore(0x300, hash)
        }

        {
            let x := calldataload(0x180)
            mstore(0x320, x)
            let y := calldataload(0x1a0)
            mstore(0x340, y)
            success := and(validate_ec_point(x, y), success)
        }

        {
            let x := calldataload(0x1c0)
            mstore(0x360, x)
            let y := calldataload(0x1e0)
            mstore(0x380, y)
            success := and(validate_ec_point(x, y), success)
        }
mstore(0x3a0, keccak256(0x300, 160))
{
            let hash := mload(0x3a0)
            mstore(0x3c0, mod(hash, f_q))
            mstore(0x3e0, hash)
        }
mstore(0x400, mod(calldataload(0x200), f_q))
mstore(0x420, mod(calldataload(0x220), f_q))
mstore(0x440, mod(calldataload(0x240), f_q))
mstore(0x460, mod(calldataload(0x260), f_q))
mstore(0x480, mod(calldataload(0x280), f_q))
mstore(0x4a0, mod(calldataload(0x2a0), f_q))
mstore(0x4c0, mod(calldataload(0x2c0), f_q))
mstore(0x4e0, mod(calldataload(0x2e0), f_q))
mstore(0x500, mod(calldataload(0x300), f_q))
mstore(0x520, mod(calldataload(0x320), f_q))
mstore(0x540, mod(calldataload(0x340), f_q))
mstore(0x560, mod(calldataload(0x360), f_q))
mstore(0x580, mod(calldataload(0x380), f_q))
mstore(0x5a0, mod(calldataload(0x3a0), f_q))
mstore(0x5c0, mod(calldataload(0x3c0), f_q))
mstore(0x5e0, mod(calldataload(0x3e0), f_q))
mstore(0x600, mod(calldataload(0x400), f_q))
mstore(0x620, mod(calldataload(0x420), f_q))
mstore(0x640, keccak256(0x3e0, 608))
{
            let hash := mload(0x640)
            mstore(0x660, mod(hash, f_q))
            mstore(0x680, hash)
        }
mstore8(1696, 1)
mstore(0x6a0, keccak256(0x680, 33))
{
            let hash := mload(0x6a0)
            mstore(0x6c0, mod(hash, f_q))
            mstore(0x6e0, hash)
        }

        {
            let x := calldataload(0x440)
            mstore(0x700, x)
            let y := calldataload(0x460)
            mstore(0x720, y)
            success := and(validate_ec_point(x, y), success)
        }
mstore(0x740, keccak256(0x6e0, 96))
{
            let hash := mload(0x740)
            mstore(0x760, mod(hash, f_q))
            mstore(0x780, hash)
        }

        {
            let x := calldataload(0x480)
            mstore(0x7a0, x)
            let y := calldataload(0x4a0)
            mstore(0x7c0, y)
            success := and(validate_ec_point(x, y), success)
        }
mstore(0x7e0, mulmod(mload(0x3c0), mload(0x3c0), f_q))
mstore(0x800, mulmod(mload(0x7e0), mload(0x7e0), f_q))
mstore(0x820, mulmod(mload(0x800), mload(0x800), f_q))
mstore(0x840, mulmod(mload(0x820), mload(0x820), f_q))
mstore(0x860, mulmod(mload(0x840), mload(0x840), f_q))
mstore(0x880, mulmod(mload(0x860), mload(0x860), f_q))
mstore(0x8a0, mulmod(mload(0x880), mload(0x880), f_q))
mstore(0x8c0, mulmod(mload(0x8a0), mload(0x8a0), f_q))
mstore(0x8e0, addmod(mload(0x8c0), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q))
mstore(0x900, mulmod(mload(0x8e0), 21802741923121153053409505722814863857733722351976909209543133076471996743681, f_q))
mstore(0x920, mulmod(mload(0x900), 20758584870909399147353101743951440498792496266892767224442261535037899349676, f_q))
mstore(0x940, addmod(mload(0x3c0), 1129658000929876074893304001305834589755868133523267119255942651537909145941, f_q))
mstore(0x960, mulmod(mload(0x900), 10167250710514084151592399827148084713285735496006016499965216114801401041468, f_q))
mstore(0x980, addmod(mload(0x3c0), 11720992161325191070654005918109190375262628904410017843732988071774407454149, f_q))
mstore(0x9a0, mulmod(mload(0x900), 15620430616972136973029697708057142747056669543503469918700292712864029815878, f_q))
mstore(0x9c0, addmod(mload(0x3c0), 6267812254867138249216708037200132341491694856912564424997911473711778679739, f_q))
mstore(0x9e0, mulmod(mload(0x900), 4658854783519236281304787251426829785380272013053939496434657852755686889074, f_q))
mstore(0xa00, addmod(mload(0x3c0), 17229388088320038940941618493830445303168092387362094847263546333820121606543, f_q))
mstore(0xa20, mulmod(mload(0x900), 11423757818648818765461327411617109120243501240676889555478397529313037714234, f_q))
mstore(0xa40, addmod(mload(0x3c0), 10464485053190456456785078333640165968304863159739144788219806657262770781383, f_q))
mstore(0xa60, mulmod(mload(0x900), 13677048343952077794467995888380402608453928821079198134318291065290235358859, f_q))
mstore(0xa80, addmod(mload(0x3c0), 8211194527887197427778409856876872480094435579336836209379913121285573136758, f_q))
mstore(0xaa0, mulmod(mload(0x900), 14158528901797138466244491986759313854666262535363044392173788062030301470987, f_q))
mstore(0xac0, addmod(mload(0x3c0), 7729713970042136756001913758497961233882101865052989951524416124545507024630, f_q))
mstore(0xae0, mulmod(mload(0x900), 1, f_q))
mstore(0xb00, addmod(mload(0x3c0), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q))
mstore(0xb20, mulmod(mload(0x900), 7393649265675507591155086225434297871937368251641985215568891852805958167681, f_q))
mstore(0xb40, addmod(mload(0x3c0), 14494593606163767631091319519822977216610996148774049128129312333769850327936, f_q))
{
            let prod := mload(0x940)

                prod := mulmod(mload(0x980), prod, f_q)
                mstore(0xb60, prod)
            
                prod := mulmod(mload(0x9c0), prod, f_q)
                mstore(0xb80, prod)
            
                prod := mulmod(mload(0xa00), prod, f_q)
                mstore(0xba0, prod)
            
                prod := mulmod(mload(0xa40), prod, f_q)
                mstore(0xbc0, prod)
            
                prod := mulmod(mload(0xa80), prod, f_q)
                mstore(0xbe0, prod)
            
                prod := mulmod(mload(0xac0), prod, f_q)
                mstore(0xc00, prod)
            
                prod := mulmod(mload(0xb00), prod, f_q)
                mstore(0xc20, prod)
            
                prod := mulmod(mload(0xb40), prod, f_q)
                mstore(0xc40, prod)
            
                prod := mulmod(mload(0x8e0), prod, f_q)
                mstore(0xc60, prod)
            
        }
mstore(0xca0, 32)
mstore(0xcc0, 32)
mstore(0xce0, 32)
mstore(0xd00, mload(0xc60))
mstore(0xd20, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
mstore(0xd40, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
success := and(eq(staticcall(gas(), 0x5, 0xca0, 0xc0, 0xc80, 0x20), 1), success)
{
            
            let inv := mload(0xc80)
            let v
        
                    v := mload(0x8e0)
                    mstore(2272, mulmod(mload(0xc40), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xb40)
                    mstore(2880, mulmod(mload(0xc20), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xb00)
                    mstore(2816, mulmod(mload(0xc00), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xac0)
                    mstore(2752, mulmod(mload(0xbe0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xa80)
                    mstore(2688, mulmod(mload(0xbc0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xa40)
                    mstore(2624, mulmod(mload(0xba0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xa00)
                    mstore(2560, mulmod(mload(0xb80), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x9c0)
                    mstore(2496, mulmod(mload(0xb60), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x980)
                    mstore(2432, mulmod(mload(0x940), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                mstore(0x940, inv)

        }
mstore(0xd60, mulmod(mload(0x920), mload(0x940), f_q))
mstore(0xd80, mulmod(mload(0x960), mload(0x980), f_q))
mstore(0xda0, mulmod(mload(0x9a0), mload(0x9c0), f_q))
mstore(0xdc0, mulmod(mload(0x9e0), mload(0xa00), f_q))
mstore(0xde0, mulmod(mload(0xa20), mload(0xa40), f_q))
mstore(0xe00, mulmod(mload(0xa60), mload(0xa80), f_q))
mstore(0xe20, mulmod(mload(0xaa0), mload(0xac0), f_q))
mstore(0xe40, mulmod(mload(0xae0), mload(0xb00), f_q))
mstore(0xe60, mulmod(mload(0xb20), mload(0xb40), f_q))
{
            let result := mulmod(mload(0xe40), mload(0x20), f_q)
result := addmod(mulmod(mload(0xe60), mload(0x40), f_q), result, f_q)
mstore(3712, result)
        }
mstore(0xea0, mulmod(mload(0x440), mload(0x420), f_q))
mstore(0xec0, addmod(mload(0x400), mload(0xea0), f_q))
mstore(0xee0, addmod(mload(0xec0), sub(f_q, mload(0x460)), f_q))
mstore(0xf00, mulmod(mload(0xee0), mload(0x4a0), f_q))
mstore(0xf20, mulmod(mload(0x2e0), mload(0xf00), f_q))
mstore(0xf40, addmod(1, sub(f_q, mload(0x540)), f_q))
mstore(0xf60, mulmod(mload(0xf40), mload(0xe40), f_q))
mstore(0xf80, addmod(mload(0xf20), mload(0xf60), f_q))
mstore(0xfa0, mulmod(mload(0x2e0), mload(0xf80), f_q))
mstore(0xfc0, mulmod(mload(0x600), mload(0x600), f_q))
mstore(0xfe0, addmod(mload(0xfc0), sub(f_q, mload(0x600)), f_q))
mstore(0x1000, mulmod(mload(0xfe0), mload(0xd60), f_q))
mstore(0x1020, addmod(mload(0xfa0), mload(0x1000), f_q))
mstore(0x1040, mulmod(mload(0x2e0), mload(0x1020), f_q))
mstore(0x1060, addmod(mload(0x5a0), sub(f_q, mload(0x580)), f_q))
mstore(0x1080, mulmod(mload(0x1060), mload(0xe40), f_q))
mstore(0x10a0, addmod(mload(0x1040), mload(0x1080), f_q))
mstore(0x10c0, mulmod(mload(0x2e0), mload(0x10a0), f_q))
mstore(0x10e0, addmod(mload(0x600), sub(f_q, mload(0x5e0)), f_q))
mstore(0x1100, mulmod(mload(0x10e0), mload(0xe40), f_q))
mstore(0x1120, addmod(mload(0x10c0), mload(0x1100), f_q))
mstore(0x1140, mulmod(mload(0x2e0), mload(0x1120), f_q))
mstore(0x1160, addmod(1, sub(f_q, mload(0xd60)), f_q))
mstore(0x1180, addmod(mload(0xd80), mload(0xda0), f_q))
mstore(0x11a0, addmod(mload(0x1180), mload(0xdc0), f_q))
mstore(0x11c0, addmod(mload(0x11a0), mload(0xde0), f_q))
mstore(0x11e0, addmod(mload(0x11c0), mload(0xe00), f_q))
mstore(0x1200, addmod(mload(0x11e0), mload(0xe20), f_q))
mstore(0x1220, addmod(mload(0x1160), sub(f_q, mload(0x1200)), f_q))
mstore(0x1240, mulmod(mload(0x4e0), mload(0x120), f_q))
mstore(0x1260, addmod(mload(0x480), mload(0x1240), f_q))
mstore(0x1280, addmod(mload(0x1260), mload(0x180), f_q))
mstore(0x12a0, mulmod(mload(0x1280), mload(0x560), f_q))
mstore(0x12c0, mulmod(1, mload(0x120), f_q))
mstore(0x12e0, mulmod(mload(0x3c0), mload(0x12c0), f_q))
mstore(0x1300, addmod(mload(0x480), mload(0x12e0), f_q))
mstore(0x1320, addmod(mload(0x1300), mload(0x180), f_q))
mstore(0x1340, mulmod(mload(0x1320), mload(0x540), f_q))
mstore(0x1360, addmod(mload(0x12a0), sub(f_q, mload(0x1340)), f_q))
mstore(0x1380, mulmod(mload(0x1360), mload(0x1220), f_q))
mstore(0x13a0, addmod(mload(0x1140), mload(0x1380), f_q))
mstore(0x13c0, mulmod(mload(0x2e0), mload(0x13a0), f_q))
mstore(0x13e0, mulmod(mload(0x500), mload(0x120), f_q))
mstore(0x1400, addmod(mload(0x400), mload(0x13e0), f_q))
mstore(0x1420, addmod(mload(0x1400), mload(0x180), f_q))
mstore(0x1440, mulmod(mload(0x1420), mload(0x5c0), f_q))
mstore(0x1460, mulmod(4131629893567559867359510883348571134090853742863529169391034518566172092834, mload(0x120), f_q))
mstore(0x1480, mulmod(mload(0x3c0), mload(0x1460), f_q))
mstore(0x14a0, addmod(mload(0x400), mload(0x1480), f_q))
mstore(0x14c0, addmod(mload(0x14a0), mload(0x180), f_q))
mstore(0x14e0, mulmod(mload(0x14c0), mload(0x5a0), f_q))
mstore(0x1500, addmod(mload(0x1440), sub(f_q, mload(0x14e0)), f_q))
mstore(0x1520, mulmod(mload(0x1500), mload(0x1220), f_q))
mstore(0x1540, addmod(mload(0x13c0), mload(0x1520), f_q))
mstore(0x1560, mulmod(mload(0x2e0), mload(0x1540), f_q))
mstore(0x1580, mulmod(mload(0x520), mload(0x120), f_q))
mstore(0x15a0, addmod(mload(0xe80), mload(0x1580), f_q))
mstore(0x15c0, addmod(mload(0x15a0), mload(0x180), f_q))
mstore(0x15e0, mulmod(mload(0x15c0), mload(0x620), f_q))
mstore(0x1600, mulmod(8910878055287538404433155982483128285667088683464058436815641868457422632747, mload(0x120), f_q))
mstore(0x1620, mulmod(mload(0x3c0), mload(0x1600), f_q))
mstore(0x1640, addmod(mload(0xe80), mload(0x1620), f_q))
mstore(0x1660, addmod(mload(0x1640), mload(0x180), f_q))
mstore(0x1680, mulmod(mload(0x1660), mload(0x600), f_q))
mstore(0x16a0, addmod(mload(0x15e0), sub(f_q, mload(0x1680)), f_q))
mstore(0x16c0, mulmod(mload(0x16a0), mload(0x1220), f_q))
mstore(0x16e0, addmod(mload(0x1560), mload(0x16c0), f_q))
mstore(0x1700, mulmod(mload(0x8c0), mload(0x8c0), f_q))
mstore(0x1720, mulmod(1, mload(0x8c0), f_q))
mstore(0x1740, mulmod(mload(0x16e0), mload(0x8e0), f_q))
mstore(0x1760, mulmod(mload(0x7e0), mload(0x3c0), f_q))
mstore(0x1780, mulmod(mload(0x1760), mload(0x3c0), f_q))
mstore(0x17a0, mulmod(mload(0x3c0), 1, f_q))
mstore(0x17c0, addmod(mload(0x760), sub(f_q, mload(0x17a0)), f_q))
mstore(0x17e0, mulmod(mload(0x3c0), 7393649265675507591155086225434297871937368251641985215568891852805958167681, f_q))
mstore(0x1800, addmod(mload(0x760), sub(f_q, mload(0x17e0)), f_q))
mstore(0x1820, mulmod(mload(0x3c0), 11155988749590188555567104370587191404739761262261394640056258000903015121241, f_q))
mstore(0x1840, addmod(mload(0x760), sub(f_q, mload(0x1820)), f_q))
mstore(0x1860, mulmod(mload(0x3c0), 18154240498369470423574571952998640420834620155273666494480695920805672807787, f_q))
mstore(0x1880, addmod(mload(0x760), sub(f_q, mload(0x1860)), f_q))
mstore(0x18a0, mulmod(mload(0x3c0), 20758584870909399147353101743951440498792496266892767224442261535037899349676, f_q))
mstore(0x18c0, addmod(mload(0x760), sub(f_q, mload(0x18a0)), f_q))
{
            let result := mulmod(mload(0x760), mulmod(mload(0x1760), 18415698946526084509976977320612806817095070788197900397719297592912785189068, f_q), f_q)
result := addmod(mulmod(mload(0x3c0), mulmod(mload(0x1760), 3472543925313190712269428424644468271453293612218133945978906593663023306549, f_q), f_q), result, f_q)
mstore(6368, result)
        }
{
            let result := mulmod(mload(0x760), mulmod(mload(0x1760), 9865001430013576278949420808731725697186727577052337440160705518735479035068, f_q), f_q)
result := addmod(mulmod(mload(0x3c0), mulmod(mload(0x1760), 7931066905517270007936115525433944154882167745569736933819373741856604814589, f_q), f_q), result, f_q)
mstore(6400, result)
        }
{
            let result := mulmod(mload(0x760), mulmod(mload(0x1760), 7931066905517270007936115525433944154882167745569736933819373741856604814589, f_q), f_q)
result := addmod(mulmod(mload(0x3c0), mulmod(mload(0x1760), 19630453251238510738018245388067127323655793125469848545103409263265010328719, f_q), f_q), result, f_q)
mstore(6432, result)
        }
{
            let result := mulmod(mload(0x760), mulmod(mload(0x1760), 5695842778102747778509034695988642605769585899828851741968238014234304628606, f_q), f_q)
result := addmod(mulmod(mload(0x3c0), mulmod(mload(0x1760), 15378771241984742035678516446746373331384495577914342478186776392464509245195, f_q), f_q), result, f_q)
mstore(6464, result)
        }
mstore(0x1960, mulmod(1, mload(0x17c0), f_q))
mstore(0x1980, mulmod(mload(0x1960), mload(0x1800), f_q))
mstore(0x19a0, mulmod(mload(0x1980), mload(0x1880), f_q))
mstore(0x19c0, mulmod(mload(0x19a0), mload(0x1840), f_q))
{
            let result := mulmod(mload(0x760), mulmod(mload(0x7e0), 3903259445768452635330617603019621431104235377887298403652266913533352019729, f_q), f_q)
result := addmod(mulmod(mload(0x3c0), mulmod(mload(0x7e0), 17984983426070822586915788142237653657444129022528735940045937273042456475888, f_q), f_q), result, f_q)
mstore(6624, result)
        }
{
            let result := mulmod(mload(0x760), mulmod(mload(0x7e0), 21351925393089277828180187644367698334404012674518432003388849488236212948314, f_q), f_q)
result := addmod(mulmod(mload(0x3c0), mulmod(mload(0x7e0), 12451431655237334689444765463320507049865792940509725273159514517965286460956, f_q), f_q), result, f_q)
mstore(6656, result)
        }
{
            let result := mulmod(mload(0x760), mulmod(mload(0x7e0), 17119090841049276552166839986316436727825703667004564506997099339693416483620, f_q), f_q)
result := addmod(mulmod(mload(0x3c0), mulmod(mload(0x7e0), 20250019847959072277586046471599117511627076165218452044546814788771537370971, f_q), f_q), result, f_q)
mstore(6688, result)
        }
mstore(0x1a40, mulmod(mload(0x1980), mload(0x18c0), f_q))
{
            let result := mulmod(mload(0x760), mulmod(mload(0x3c0), 14494593606163767631091319519822977216610996148774049128129312333769850327937, f_q), f_q)
result := addmod(mulmod(mload(0x3c0), mulmod(mload(0x3c0), 7393649265675507591155086225434297871937368251641985215568891852805958167680, f_q), f_q), result, f_q)
mstore(6752, result)
        }
{
            let result := mulmod(mload(0x760), mulmod(mload(0x3c0), 7393649265675507591155086225434297871937368251641985215568891852805958167680, f_q), f_q)
result := addmod(mulmod(mload(0x3c0), mulmod(mload(0x3c0), 11127651639145312389826920017692932539651112496784353064786400118576093855511, f_q), f_q), result, f_q)
mstore(6784, result)
        }
{
            let result := mulmod(mload(0x760), 1, f_q)
result := addmod(mulmod(mload(0x3c0), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q), result, f_q)
mstore(6816, result)
        }
{
            let prod := mload(0x18e0)

                prod := mulmod(mload(0x1900), prod, f_q)
                mstore(0x1ac0, prod)
            
                prod := mulmod(mload(0x1920), prod, f_q)
                mstore(0x1ae0, prod)
            
                prod := mulmod(mload(0x1940), prod, f_q)
                mstore(0x1b00, prod)
            
                prod := mulmod(mload(0x19e0), prod, f_q)
                mstore(0x1b20, prod)
            
                prod := mulmod(mload(0x1a00), prod, f_q)
                mstore(0x1b40, prod)
            
                prod := mulmod(mload(0x1a20), prod, f_q)
                mstore(0x1b60, prod)
            
                prod := mulmod(mload(0x1a40), prod, f_q)
                mstore(0x1b80, prod)
            
                prod := mulmod(mload(0x1a60), prod, f_q)
                mstore(0x1ba0, prod)
            
                prod := mulmod(mload(0x1a80), prod, f_q)
                mstore(0x1bc0, prod)
            
                prod := mulmod(mload(0x1980), prod, f_q)
                mstore(0x1be0, prod)
            
                prod := mulmod(mload(0x1aa0), prod, f_q)
                mstore(0x1c00, prod)
            
                prod := mulmod(mload(0x1960), prod, f_q)
                mstore(0x1c20, prod)
            
        }
mstore(0x1c60, 32)
mstore(0x1c80, 32)
mstore(0x1ca0, 32)
mstore(0x1cc0, mload(0x1c20))
mstore(0x1ce0, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
mstore(0x1d00, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
success := and(eq(staticcall(gas(), 0x5, 0x1c60, 0xc0, 0x1c40, 0x20), 1), success)
{
            
            let inv := mload(0x1c40)
            let v
        
                    v := mload(0x1960)
                    mstore(6496, mulmod(mload(0x1c00), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1aa0)
                    mstore(6816, mulmod(mload(0x1be0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1980)
                    mstore(6528, mulmod(mload(0x1bc0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1a80)
                    mstore(6784, mulmod(mload(0x1ba0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1a60)
                    mstore(6752, mulmod(mload(0x1b80), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1a40)
                    mstore(6720, mulmod(mload(0x1b60), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1a20)
                    mstore(6688, mulmod(mload(0x1b40), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1a00)
                    mstore(6656, mulmod(mload(0x1b20), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x19e0)
                    mstore(6624, mulmod(mload(0x1b00), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1940)
                    mstore(6464, mulmod(mload(0x1ae0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1920)
                    mstore(6432, mulmod(mload(0x1ac0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1900)
                    mstore(6400, mulmod(mload(0x18e0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                mstore(0x18e0, inv)

        }
{
            let result := mload(0x18e0)
result := addmod(mload(0x1900), result, f_q)
result := addmod(mload(0x1920), result, f_q)
result := addmod(mload(0x1940), result, f_q)
mstore(7456, result)
        }
mstore(0x1d40, mulmod(mload(0x19c0), mload(0x1a40), f_q))
{
            let result := mload(0x19e0)
result := addmod(mload(0x1a00), result, f_q)
result := addmod(mload(0x1a20), result, f_q)
mstore(7520, result)
        }
mstore(0x1d80, mulmod(mload(0x19c0), mload(0x1980), f_q))
{
            let result := mload(0x1a60)
result := addmod(mload(0x1a80), result, f_q)
mstore(7584, result)
        }
mstore(0x1dc0, mulmod(mload(0x19c0), mload(0x1960), f_q))
{
            let result := mload(0x1aa0)
mstore(7648, result)
        }
{
            let prod := mload(0x1d20)

                prod := mulmod(mload(0x1d60), prod, f_q)
                mstore(0x1e00, prod)
            
                prod := mulmod(mload(0x1da0), prod, f_q)
                mstore(0x1e20, prod)
            
                prod := mulmod(mload(0x1de0), prod, f_q)
                mstore(0x1e40, prod)
            
        }
mstore(0x1e80, 32)
mstore(0x1ea0, 32)
mstore(0x1ec0, 32)
mstore(0x1ee0, mload(0x1e40))
mstore(0x1f00, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
mstore(0x1f20, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
success := and(eq(staticcall(gas(), 0x5, 0x1e80, 0xc0, 0x1e60, 0x20), 1), success)
{
            
            let inv := mload(0x1e60)
            let v
        
                    v := mload(0x1de0)
                    mstore(7648, mulmod(mload(0x1e20), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1da0)
                    mstore(7584, mulmod(mload(0x1e00), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1d60)
                    mstore(7520, mulmod(mload(0x1d20), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                mstore(0x1d20, inv)

        }
mstore(0x1f40, mulmod(mload(0x1d40), mload(0x1d60), f_q))
mstore(0x1f60, mulmod(mload(0x1d80), mload(0x1da0), f_q))
mstore(0x1f80, mulmod(mload(0x1dc0), mload(0x1de0), f_q))
mstore(0x1fa0, mulmod(mload(0x660), mload(0x660), f_q))
mstore(0x1fc0, mulmod(mload(0x1fa0), mload(0x660), f_q))
mstore(0x1fe0, mulmod(mload(0x1fc0), mload(0x660), f_q))
mstore(0x2000, mulmod(mload(0x1fe0), mload(0x660), f_q))
mstore(0x2020, mulmod(mload(0x2000), mload(0x660), f_q))
mstore(0x2040, mulmod(mload(0x2020), mload(0x660), f_q))
mstore(0x2060, mulmod(mload(0x6c0), mload(0x6c0), f_q))
mstore(0x2080, mulmod(mload(0x2060), mload(0x6c0), f_q))
mstore(0x20a0, mulmod(mload(0x2080), mload(0x6c0), f_q))
{
            let result := mulmod(mload(0x400), mload(0x18e0), f_q)
result := addmod(mulmod(mload(0x420), mload(0x1900), f_q), result, f_q)
result := addmod(mulmod(mload(0x440), mload(0x1920), f_q), result, f_q)
result := addmod(mulmod(mload(0x460), mload(0x1940), f_q), result, f_q)
mstore(8384, result)
        }
mstore(0x20e0, mulmod(mload(0x20c0), mload(0x1d20), f_q))
mstore(0x2100, mulmod(sub(f_q, mload(0x20e0)), 1, f_q))
mstore(0x2120, mulmod(mload(0x2100), 1, f_q))
mstore(0x2140, mulmod(1, mload(0x1d40), f_q))
{
            let result := mulmod(mload(0x540), mload(0x19e0), f_q)
result := addmod(mulmod(mload(0x560), mload(0x1a00), f_q), result, f_q)
result := addmod(mulmod(mload(0x580), mload(0x1a20), f_q), result, f_q)
mstore(8544, result)
        }
mstore(0x2180, mulmod(mload(0x2160), mload(0x1f40), f_q))
mstore(0x21a0, mulmod(sub(f_q, mload(0x2180)), 1, f_q))
mstore(0x21c0, mulmod(mload(0x2140), 1, f_q))
{
            let result := mulmod(mload(0x5a0), mload(0x19e0), f_q)
result := addmod(mulmod(mload(0x5c0), mload(0x1a00), f_q), result, f_q)
result := addmod(mulmod(mload(0x5e0), mload(0x1a20), f_q), result, f_q)
mstore(8672, result)
        }
mstore(0x2200, mulmod(mload(0x21e0), mload(0x1f40), f_q))
mstore(0x2220, mulmod(sub(f_q, mload(0x2200)), mload(0x660), f_q))
mstore(0x2240, mulmod(mload(0x2140), mload(0x660), f_q))
mstore(0x2260, addmod(mload(0x21a0), mload(0x2220), f_q))
mstore(0x2280, mulmod(mload(0x2260), mload(0x6c0), f_q))
mstore(0x22a0, mulmod(mload(0x21c0), mload(0x6c0), f_q))
mstore(0x22c0, mulmod(mload(0x2240), mload(0x6c0), f_q))
mstore(0x22e0, addmod(mload(0x2120), mload(0x2280), f_q))
mstore(0x2300, mulmod(1, mload(0x1d80), f_q))
{
            let result := mulmod(mload(0x600), mload(0x1a60), f_q)
result := addmod(mulmod(mload(0x620), mload(0x1a80), f_q), result, f_q)
mstore(8992, result)
        }
mstore(0x2340, mulmod(mload(0x2320), mload(0x1f60), f_q))
mstore(0x2360, mulmod(sub(f_q, mload(0x2340)), 1, f_q))
mstore(0x2380, mulmod(mload(0x2300), 1, f_q))
mstore(0x23a0, mulmod(mload(0x2360), mload(0x2060), f_q))
mstore(0x23c0, mulmod(mload(0x2380), mload(0x2060), f_q))
mstore(0x23e0, addmod(mload(0x22e0), mload(0x23a0), f_q))
mstore(0x2400, mulmod(1, mload(0x1dc0), f_q))
{
            let result := mulmod(mload(0x480), mload(0x1aa0), f_q)
mstore(9248, result)
        }
mstore(0x2440, mulmod(mload(0x2420), mload(0x1f80), f_q))
mstore(0x2460, mulmod(sub(f_q, mload(0x2440)), 1, f_q))
mstore(0x2480, mulmod(mload(0x2400), 1, f_q))
{
            let result := mulmod(mload(0x4a0), mload(0x1aa0), f_q)
mstore(9376, result)
        }
mstore(0x24c0, mulmod(mload(0x24a0), mload(0x1f80), f_q))
mstore(0x24e0, mulmod(sub(f_q, mload(0x24c0)), mload(0x660), f_q))
mstore(0x2500, mulmod(mload(0x2400), mload(0x660), f_q))
mstore(0x2520, addmod(mload(0x2460), mload(0x24e0), f_q))
{
            let result := mulmod(mload(0x4e0), mload(0x1aa0), f_q)
mstore(9536, result)
        }
mstore(0x2560, mulmod(mload(0x2540), mload(0x1f80), f_q))
mstore(0x2580, mulmod(sub(f_q, mload(0x2560)), mload(0x1fa0), f_q))
mstore(0x25a0, mulmod(mload(0x2400), mload(0x1fa0), f_q))
mstore(0x25c0, addmod(mload(0x2520), mload(0x2580), f_q))
{
            let result := mulmod(mload(0x500), mload(0x1aa0), f_q)
mstore(9696, result)
        }
mstore(0x2600, mulmod(mload(0x25e0), mload(0x1f80), f_q))
mstore(0x2620, mulmod(sub(f_q, mload(0x2600)), mload(0x1fc0), f_q))
mstore(0x2640, mulmod(mload(0x2400), mload(0x1fc0), f_q))
mstore(0x2660, addmod(mload(0x25c0), mload(0x2620), f_q))
{
            let result := mulmod(mload(0x520), mload(0x1aa0), f_q)
mstore(9856, result)
        }
mstore(0x26a0, mulmod(mload(0x2680), mload(0x1f80), f_q))
mstore(0x26c0, mulmod(sub(f_q, mload(0x26a0)), mload(0x1fe0), f_q))
mstore(0x26e0, mulmod(mload(0x2400), mload(0x1fe0), f_q))
mstore(0x2700, addmod(mload(0x2660), mload(0x26c0), f_q))
mstore(0x2720, mulmod(mload(0x1720), mload(0x1dc0), f_q))
{
            let result := mulmod(mload(0x1740), mload(0x1aa0), f_q)
mstore(10048, result)
        }
mstore(0x2760, mulmod(mload(0x2740), mload(0x1f80), f_q))
mstore(0x2780, mulmod(sub(f_q, mload(0x2760)), mload(0x2000), f_q))
mstore(0x27a0, mulmod(mload(0x2400), mload(0x2000), f_q))
mstore(0x27c0, mulmod(mload(0x2720), mload(0x2000), f_q))
mstore(0x27e0, addmod(mload(0x2700), mload(0x2780), f_q))
{
            let result := mulmod(mload(0x4c0), mload(0x1aa0), f_q)
mstore(10240, result)
        }
mstore(0x2820, mulmod(mload(0x2800), mload(0x1f80), f_q))
mstore(0x2840, mulmod(sub(f_q, mload(0x2820)), mload(0x2020), f_q))
mstore(0x2860, mulmod(mload(0x2400), mload(0x2020), f_q))
mstore(0x2880, addmod(mload(0x27e0), mload(0x2840), f_q))
mstore(0x28a0, mulmod(mload(0x2880), mload(0x2080), f_q))
mstore(0x28c0, mulmod(mload(0x2480), mload(0x2080), f_q))
mstore(0x28e0, mulmod(mload(0x2500), mload(0x2080), f_q))
mstore(0x2900, mulmod(mload(0x25a0), mload(0x2080), f_q))
mstore(0x2920, mulmod(mload(0x2640), mload(0x2080), f_q))
mstore(0x2940, mulmod(mload(0x26e0), mload(0x2080), f_q))
mstore(0x2960, mulmod(mload(0x27a0), mload(0x2080), f_q))
mstore(0x2980, mulmod(mload(0x27c0), mload(0x2080), f_q))
mstore(0x29a0, mulmod(mload(0x2860), mload(0x2080), f_q))
mstore(0x29c0, addmod(mload(0x23e0), mload(0x28a0), f_q))
mstore(0x29e0, mulmod(1, mload(0x19c0), f_q))
mstore(0x2a00, mulmod(1, mload(0x760), f_q))
mstore(0x2a20, 0x0000000000000000000000000000000000000000000000000000000000000001)
                    mstore(0x2a40, 0x0000000000000000000000000000000000000000000000000000000000000002)
mstore(0x2a60, mload(0x29c0))
success := and(eq(staticcall(gas(), 0x7, 0x2a20, 0x60, 0x2a20, 0x40), 1), success)
mstore(0x2a80, mload(0x2a20))
                    mstore(0x2aa0, mload(0x2a40))
mstore(0x2ac0, mload(0x60))
                    mstore(0x2ae0, mload(0x80))
success := and(eq(staticcall(gas(), 0x6, 0x2a80, 0x80, 0x2a80, 0x40), 1), success)
mstore(0x2b00, mload(0x1c0))
                    mstore(0x2b20, mload(0x1e0))
mstore(0x2b40, mload(0x22a0))
success := and(eq(staticcall(gas(), 0x7, 0x2b00, 0x60, 0x2b00, 0x40), 1), success)
mstore(0x2b60, mload(0x2a80))
                    mstore(0x2b80, mload(0x2aa0))
mstore(0x2ba0, mload(0x2b00))
                    mstore(0x2bc0, mload(0x2b20))
success := and(eq(staticcall(gas(), 0x6, 0x2b60, 0x80, 0x2b60, 0x40), 1), success)
mstore(0x2be0, mload(0x200))
                    mstore(0x2c00, mload(0x220))
mstore(0x2c20, mload(0x22c0))
success := and(eq(staticcall(gas(), 0x7, 0x2be0, 0x60, 0x2be0, 0x40), 1), success)
mstore(0x2c40, mload(0x2b60))
                    mstore(0x2c60, mload(0x2b80))
mstore(0x2c80, mload(0x2be0))
                    mstore(0x2ca0, mload(0x2c00))
success := and(eq(staticcall(gas(), 0x6, 0x2c40, 0x80, 0x2c40, 0x40), 1), success)
mstore(0x2cc0, mload(0x240))
                    mstore(0x2ce0, mload(0x260))
mstore(0x2d00, mload(0x23c0))
success := and(eq(staticcall(gas(), 0x7, 0x2cc0, 0x60, 0x2cc0, 0x40), 1), success)
mstore(0x2d20, mload(0x2c40))
                    mstore(0x2d40, mload(0x2c60))
mstore(0x2d60, mload(0x2cc0))
                    mstore(0x2d80, mload(0x2ce0))
success := and(eq(staticcall(gas(), 0x6, 0x2d20, 0x80, 0x2d20, 0x40), 1), success)
mstore(0x2da0, 0x27df1cb00c8e3fec94bfefdf8e0b047138751b78eae854a7d5b5ab10ce343235)
                    mstore(0x2dc0, 0x2e45034de441b2e06c0e43a08eec5a2461332575697e07bfdf858f2f0fbf9f5e)
mstore(0x2de0, mload(0x28c0))
success := and(eq(staticcall(gas(), 0x7, 0x2da0, 0x60, 0x2da0, 0x40), 1), success)
mstore(0x2e00, mload(0x2d20))
                    mstore(0x2e20, mload(0x2d40))
mstore(0x2e40, mload(0x2da0))
                    mstore(0x2e60, mload(0x2dc0))
success := and(eq(staticcall(gas(), 0x6, 0x2e00, 0x80, 0x2e00, 0x40), 1), success)
mstore(0x2e80, 0x142591a0c10663aacb9f01afed5a025c07759a8673213b850553e8e229808d58)
                    mstore(0x2ea0, 0x13114bdb278629470325faf4d90c8d2c716cccba1ee6ff82980ba5188b41874f)
mstore(0x2ec0, mload(0x28e0))
success := and(eq(staticcall(gas(), 0x7, 0x2e80, 0x60, 0x2e80, 0x40), 1), success)
mstore(0x2ee0, mload(0x2e00))
                    mstore(0x2f00, mload(0x2e20))
mstore(0x2f20, mload(0x2e80))
                    mstore(0x2f40, mload(0x2ea0))
success := and(eq(staticcall(gas(), 0x6, 0x2ee0, 0x80, 0x2ee0, 0x40), 1), success)
mstore(0x2f60, 0x2e4547979543efa0ee18e54aad7b0fedf7891247e1c5a6ad721bdde3bb27b7ae)
                    mstore(0x2f80, 0x10f72add6b32d67079bd484c294064b88fd0a521fe75c555bb28edfcf0130e1b)
mstore(0x2fa0, mload(0x2900))
success := and(eq(staticcall(gas(), 0x7, 0x2f60, 0x60, 0x2f60, 0x40), 1), success)
mstore(0x2fc0, mload(0x2ee0))
                    mstore(0x2fe0, mload(0x2f00))
mstore(0x3000, mload(0x2f60))
                    mstore(0x3020, mload(0x2f80))
success := and(eq(staticcall(gas(), 0x6, 0x2fc0, 0x80, 0x2fc0, 0x40), 1), success)
mstore(0x3040, 0x2f85f631ced33a31aa45047966c1c64892fbad56ff81f33d0e2c3cf827fd2463)
                    mstore(0x3060, 0x2115ff3a78b830227154d73e0ae20a43f8f53a9af1d2b2092d1eefbdc11dfc16)
mstore(0x3080, mload(0x2920))
success := and(eq(staticcall(gas(), 0x7, 0x3040, 0x60, 0x3040, 0x40), 1), success)
mstore(0x30a0, mload(0x2fc0))
                    mstore(0x30c0, mload(0x2fe0))
mstore(0x30e0, mload(0x3040))
                    mstore(0x3100, mload(0x3060))
success := and(eq(staticcall(gas(), 0x6, 0x30a0, 0x80, 0x30a0, 0x40), 1), success)
mstore(0x3120, 0x1682b3d83b6dfafe359643740545d8c1db04460480695b9798a3142d0cc97d26)
                    mstore(0x3140, 0x1e9c0a416b4de50c5a0ee76a9ad6d896d555a6d016687f5825ac7495f95bb29d)
mstore(0x3160, mload(0x2940))
success := and(eq(staticcall(gas(), 0x7, 0x3120, 0x60, 0x3120, 0x40), 1), success)
mstore(0x3180, mload(0x30a0))
                    mstore(0x31a0, mload(0x30c0))
mstore(0x31c0, mload(0x3120))
                    mstore(0x31e0, mload(0x3140))
success := and(eq(staticcall(gas(), 0x6, 0x3180, 0x80, 0x3180, 0x40), 1), success)
mstore(0x3200, mload(0x320))
                    mstore(0x3220, mload(0x340))
mstore(0x3240, mload(0x2960))
success := and(eq(staticcall(gas(), 0x7, 0x3200, 0x60, 0x3200, 0x40), 1), success)
mstore(0x3260, mload(0x3180))
                    mstore(0x3280, mload(0x31a0))
mstore(0x32a0, mload(0x3200))
                    mstore(0x32c0, mload(0x3220))
success := and(eq(staticcall(gas(), 0x6, 0x3260, 0x80, 0x3260, 0x40), 1), success)
mstore(0x32e0, mload(0x360))
                    mstore(0x3300, mload(0x380))
mstore(0x3320, mload(0x2980))
success := and(eq(staticcall(gas(), 0x7, 0x32e0, 0x60, 0x32e0, 0x40), 1), success)
mstore(0x3340, mload(0x3260))
                    mstore(0x3360, mload(0x3280))
mstore(0x3380, mload(0x32e0))
                    mstore(0x33a0, mload(0x3300))
success := and(eq(staticcall(gas(), 0x6, 0x3340, 0x80, 0x3340, 0x40), 1), success)
mstore(0x33c0, mload(0x280))
                    mstore(0x33e0, mload(0x2a0))
mstore(0x3400, mload(0x29a0))
success := and(eq(staticcall(gas(), 0x7, 0x33c0, 0x60, 0x33c0, 0x40), 1), success)
mstore(0x3420, mload(0x3340))
                    mstore(0x3440, mload(0x3360))
mstore(0x3460, mload(0x33c0))
                    mstore(0x3480, mload(0x33e0))
success := and(eq(staticcall(gas(), 0x6, 0x3420, 0x80, 0x3420, 0x40), 1), success)
mstore(0x34a0, mload(0x700))
                    mstore(0x34c0, mload(0x720))
mstore(0x34e0, sub(f_q, mload(0x29e0)))
success := and(eq(staticcall(gas(), 0x7, 0x34a0, 0x60, 0x34a0, 0x40), 1), success)
mstore(0x3500, mload(0x3420))
                    mstore(0x3520, mload(0x3440))
mstore(0x3540, mload(0x34a0))
                    mstore(0x3560, mload(0x34c0))
success := and(eq(staticcall(gas(), 0x6, 0x3500, 0x80, 0x3500, 0x40), 1), success)
mstore(0x3580, mload(0x7a0))
                    mstore(0x35a0, mload(0x7c0))
mstore(0x35c0, mload(0x2a00))
success := and(eq(staticcall(gas(), 0x7, 0x3580, 0x60, 0x3580, 0x40), 1), success)
mstore(0x35e0, mload(0x3500))
                    mstore(0x3600, mload(0x3520))
mstore(0x3620, mload(0x3580))
                    mstore(0x3640, mload(0x35a0))
success := and(eq(staticcall(gas(), 0x6, 0x35e0, 0x80, 0x35e0, 0x40), 1), success)
mstore(0x3660, mload(0x35e0))
                    mstore(0x3680, mload(0x3600))
mstore(0x36a0, 0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2)
            mstore(0x36c0, 0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed)
            mstore(0x36e0, 0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b)
            mstore(0x3700, 0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa)
mstore(0x3720, mload(0x7a0))
                    mstore(0x3740, mload(0x7c0))
mstore(0x3760, 0x0181624e80f3d6ae28df7e01eaeab1c0e919877a3b8a6b7fbc69a6817d596ea2)
            mstore(0x3780, 0x1783d30dcb12d259bb89098addf6280fa4b653be7a152542a28f7b926e27e648)
            mstore(0x37a0, 0x00ae44489d41a0d179e2dfdc03bddd883b7109f8b6ae316a59e815c1a6b35304)
            mstore(0x37c0, 0x0b2147ab62a386bd63e6de1522109b8c9588ab466f5aadfde8c41ca3749423ee)
success := and(eq(staticcall(gas(), 0x8, 0x3660, 0x180, 0x3660, 0x20), 1), success)
success := and(eq(mload(0x3660), 1), success)

            if not(success) { revert(0, 0) }
            return(0, 0)

                }
            }
        }