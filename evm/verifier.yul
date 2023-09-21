
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
mstore(0x0, 7575750463678579894524561018471050872769803284500152784672932324894772455630)

        {
            let x := calldataload(0x20)
            mstore(0x40, x)
            let y := calldataload(0x40)
            mstore(0x60, y)
            success := and(validate_ec_point(x, y), success)
        }
mstore(0x80, keccak256(0x0, 128))
{
            let hash := mload(0x80)
            mstore(0xa0, mod(hash, f_q))
            mstore(0xc0, hash)
        }

        {
            let x := calldataload(0x60)
            mstore(0xe0, x)
            let y := calldataload(0x80)
            mstore(0x100, y)
            success := and(validate_ec_point(x, y), success)
        }

        {
            let x := calldataload(0xa0)
            mstore(0x120, x)
            let y := calldataload(0xc0)
            mstore(0x140, y)
            success := and(validate_ec_point(x, y), success)
        }
mstore(0x160, keccak256(0xc0, 160))
{
            let hash := mload(0x160)
            mstore(0x180, mod(hash, f_q))
            mstore(0x1a0, hash)
        }
mstore8(448, 1)
mstore(0x1c0, keccak256(0x1a0, 33))
{
            let hash := mload(0x1c0)
            mstore(0x1e0, mod(hash, f_q))
            mstore(0x200, hash)
        }

        {
            let x := calldataload(0xe0)
            mstore(0x220, x)
            let y := calldataload(0x100)
            mstore(0x240, y)
            success := and(validate_ec_point(x, y), success)
        }

        {
            let x := calldataload(0x120)
            mstore(0x260, x)
            let y := calldataload(0x140)
            mstore(0x280, y)
            success := and(validate_ec_point(x, y), success)
        }

        {
            let x := calldataload(0x160)
            mstore(0x2a0, x)
            let y := calldataload(0x180)
            mstore(0x2c0, y)
            success := and(validate_ec_point(x, y), success)
        }
mstore(0x2e0, keccak256(0x200, 224))
{
            let hash := mload(0x2e0)
            mstore(0x300, mod(hash, f_q))
            mstore(0x320, hash)
        }

        {
            let x := calldataload(0x1a0)
            mstore(0x340, x)
            let y := calldataload(0x1c0)
            mstore(0x360, y)
            success := and(validate_ec_point(x, y), success)
        }

        {
            let x := calldataload(0x1e0)
            mstore(0x380, x)
            let y := calldataload(0x200)
            mstore(0x3a0, y)
            success := and(validate_ec_point(x, y), success)
        }

        {
            let x := calldataload(0x220)
            mstore(0x3c0, x)
            let y := calldataload(0x240)
            mstore(0x3e0, y)
            success := and(validate_ec_point(x, y), success)
        }

        {
            let x := calldataload(0x260)
            mstore(0x400, x)
            let y := calldataload(0x280)
            mstore(0x420, y)
            success := and(validate_ec_point(x, y), success)
        }
mstore(0x440, keccak256(0x320, 288))
{
            let hash := mload(0x440)
            mstore(0x460, mod(hash, f_q))
            mstore(0x480, hash)
        }
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
mstore(0x640, mod(calldataload(0x440), f_q))
mstore(0x660, mod(calldataload(0x460), f_q))
mstore(0x680, mod(calldataload(0x480), f_q))
mstore(0x6a0, mod(calldataload(0x4a0), f_q))
mstore(0x6c0, mod(calldataload(0x4c0), f_q))
mstore(0x6e0, mod(calldataload(0x4e0), f_q))
mstore(0x700, keccak256(0x480, 640))
{
            let hash := mload(0x700)
            mstore(0x720, mod(hash, f_q))
            mstore(0x740, hash)
        }
mstore8(1888, 1)
mstore(0x760, keccak256(0x740, 33))
{
            let hash := mload(0x760)
            mstore(0x780, mod(hash, f_q))
            mstore(0x7a0, hash)
        }

        {
            let x := calldataload(0x500)
            mstore(0x7c0, x)
            let y := calldataload(0x520)
            mstore(0x7e0, y)
            success := and(validate_ec_point(x, y), success)
        }
mstore(0x800, keccak256(0x7a0, 96))
{
            let hash := mload(0x800)
            mstore(0x820, mod(hash, f_q))
            mstore(0x840, hash)
        }

        {
            let x := calldataload(0x540)
            mstore(0x860, x)
            let y := calldataload(0x560)
            mstore(0x880, y)
            success := and(validate_ec_point(x, y), success)
        }
mstore(0x8a0, mulmod(mload(0x460), mload(0x460), f_q))
mstore(0x8c0, mulmod(mload(0x8a0), mload(0x8a0), f_q))
mstore(0x8e0, mulmod(mload(0x8c0), mload(0x8c0), f_q))
mstore(0x900, mulmod(mload(0x8e0), mload(0x8e0), f_q))
mstore(0x920, mulmod(mload(0x900), mload(0x900), f_q))
mstore(0x940, mulmod(mload(0x920), mload(0x920), f_q))
mstore(0x960, mulmod(mload(0x940), mload(0x940), f_q))
mstore(0x980, mulmod(mload(0x960), mload(0x960), f_q))
mstore(0x9a0, mulmod(mload(0x980), mload(0x980), f_q))
mstore(0x9c0, mulmod(mload(0x9a0), mload(0x9a0), f_q))
mstore(0x9e0, mulmod(mload(0x9c0), mload(0x9c0), f_q))
mstore(0xa00, mulmod(mload(0x9e0), mload(0x9e0), f_q))
mstore(0xa20, mulmod(mload(0xa00), mload(0xa00), f_q))
mstore(0xa40, mulmod(mload(0xa20), mload(0xa20), f_q))
mstore(0xa60, mulmod(mload(0xa40), mload(0xa40), f_q))
mstore(0xa80, addmod(mload(0xa60), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q))
mstore(0xaa0, mulmod(mload(0xa80), 21887574895677414892802367463831943750807625009412603678587617693528122466305, f_q))
mstore(0xac0, mulmod(mload(0xaa0), 11401655310096977739023415853402087241409886155332998967297029165109544314182, f_q))
mstore(0xae0, addmod(mload(0x460), 10486587561742297483222989891855187847138478245083035376401175021466264181435, f_q))
mstore(0xb00, mulmod(mload(0xaa0), 16352530144570232727633744131804667993120004373047725463318648550785966993151, f_q))
mstore(0xb20, addmod(mload(0x460), 5535712727269042494612661613452607095428360027368308880379555635789841502466, f_q))
mstore(0xb40, mulmod(mload(0xaa0), 14553179485550867228528728261227346284647560894473765120196362074270314914987, f_q))
mstore(0xb60, addmod(mload(0x460), 7335063386288407993717677484029928803900803505942269223501842112305493580630, f_q))
mstore(0xb80, mulmod(mload(0xaa0), 4521750382223097318870644937630448302689540805369738458837210702774549763045, f_q))
mstore(0xba0, addmod(mload(0x460), 17366492489616177903375760807626826785858823595046295884860993483801258732572, f_q))
mstore(0xbc0, mulmod(mload(0xaa0), 10763352634187770026454006562738618997775638622944072507352459644433398105234, f_q))
mstore(0xbe0, addmod(mload(0x460), 11124890237651505195792399182518656090772725777471961836345744542142410390383, f_q))
mstore(0xc00, mulmod(mload(0xaa0), 21534532313823515215512181691915269261875716777293450290797415136928563006845, f_q))
mstore(0xc20, addmod(mload(0x460), 353710558015760006734224053342005826672647623122584052900789049647245488772, f_q))
mstore(0xc40, mulmod(mload(0xaa0), 14204982954615820785730815556166377574172276341958019443243371773666809943588, f_q))
mstore(0xc60, addmod(mload(0x460), 7683259917223454436515590189090897514376088058458014900454832412908998552029, f_q))
mstore(0xc80, mulmod(mload(0xaa0), 1, f_q))
mstore(0xca0, addmod(mload(0x460), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q))
{
            let prod := mload(0xae0)

                prod := mulmod(mload(0xb20), prod, f_q)
                mstore(0xcc0, prod)
            
                prod := mulmod(mload(0xb60), prod, f_q)
                mstore(0xce0, prod)
            
                prod := mulmod(mload(0xba0), prod, f_q)
                mstore(0xd00, prod)
            
                prod := mulmod(mload(0xbe0), prod, f_q)
                mstore(0xd20, prod)
            
                prod := mulmod(mload(0xc20), prod, f_q)
                mstore(0xd40, prod)
            
                prod := mulmod(mload(0xc60), prod, f_q)
                mstore(0xd60, prod)
            
                prod := mulmod(mload(0xca0), prod, f_q)
                mstore(0xd80, prod)
            
                prod := mulmod(mload(0xa80), prod, f_q)
                mstore(0xda0, prod)
            
        }
mstore(0xde0, 32)
mstore(0xe00, 32)
mstore(0xe20, 32)
mstore(0xe40, mload(0xda0))
mstore(0xe60, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
mstore(0xe80, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
success := and(eq(staticcall(gas(), 0x5, 0xde0, 0xc0, 0xdc0, 0x20), 1), success)
{
            
            let inv := mload(0xdc0)
            let v
        
                    v := mload(0xa80)
                    mstore(2688, mulmod(mload(0xd80), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xca0)
                    mstore(3232, mulmod(mload(0xd60), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xc60)
                    mstore(3168, mulmod(mload(0xd40), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xc20)
                    mstore(3104, mulmod(mload(0xd20), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xbe0)
                    mstore(3040, mulmod(mload(0xd00), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xba0)
                    mstore(2976, mulmod(mload(0xce0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xb60)
                    mstore(2912, mulmod(mload(0xcc0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xb20)
                    mstore(2848, mulmod(mload(0xae0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                mstore(0xae0, inv)

        }
mstore(0xea0, mulmod(mload(0xac0), mload(0xae0), f_q))
mstore(0xec0, mulmod(mload(0xb00), mload(0xb20), f_q))
mstore(0xee0, mulmod(mload(0xb40), mload(0xb60), f_q))
mstore(0xf00, mulmod(mload(0xb80), mload(0xba0), f_q))
mstore(0xf20, mulmod(mload(0xbc0), mload(0xbe0), f_q))
mstore(0xf40, mulmod(mload(0xc00), mload(0xc20), f_q))
mstore(0xf60, mulmod(mload(0xc40), mload(0xc60), f_q))
mstore(0xf80, mulmod(mload(0xc80), mload(0xca0), f_q))
{
            let result := mulmod(mload(0xf80), mload(0x20), f_q)
mstore(4000, result)
        }
mstore(0xfc0, mulmod(mload(0x4e0), mload(0x4c0), f_q))
mstore(0xfe0, addmod(mload(0x4a0), mload(0xfc0), f_q))
mstore(0x1000, addmod(mload(0xfe0), sub(f_q, mload(0x500)), f_q))
mstore(0x1020, mulmod(mload(0x1000), mload(0x580), f_q))
mstore(0x1040, mulmod(mload(0x300), mload(0x1020), f_q))
mstore(0x1060, addmod(1, sub(f_q, mload(0x620)), f_q))
mstore(0x1080, mulmod(mload(0x1060), mload(0xf80), f_q))
mstore(0x10a0, addmod(mload(0x1040), mload(0x1080), f_q))
mstore(0x10c0, mulmod(mload(0x300), mload(0x10a0), f_q))
mstore(0x10e0, mulmod(mload(0x620), mload(0x620), f_q))
mstore(0x1100, addmod(mload(0x10e0), sub(f_q, mload(0x620)), f_q))
mstore(0x1120, mulmod(mload(0x1100), mload(0xea0), f_q))
mstore(0x1140, addmod(mload(0x10c0), mload(0x1120), f_q))
mstore(0x1160, mulmod(mload(0x300), mload(0x1140), f_q))
mstore(0x1180, addmod(1, sub(f_q, mload(0xea0)), f_q))
mstore(0x11a0, addmod(mload(0xec0), mload(0xee0), f_q))
mstore(0x11c0, addmod(mload(0x11a0), mload(0xf00), f_q))
mstore(0x11e0, addmod(mload(0x11c0), mload(0xf20), f_q))
mstore(0x1200, addmod(mload(0x11e0), mload(0xf40), f_q))
mstore(0x1220, addmod(mload(0x1200), mload(0xf60), f_q))
mstore(0x1240, addmod(mload(0x1180), sub(f_q, mload(0x1220)), f_q))
mstore(0x1260, mulmod(mload(0x5c0), mload(0x180), f_q))
mstore(0x1280, addmod(mload(0x520), mload(0x1260), f_q))
mstore(0x12a0, addmod(mload(0x1280), mload(0x1e0), f_q))
mstore(0x12c0, mulmod(mload(0x5e0), mload(0x180), f_q))
mstore(0x12e0, addmod(mload(0x4a0), mload(0x12c0), f_q))
mstore(0x1300, addmod(mload(0x12e0), mload(0x1e0), f_q))
mstore(0x1320, mulmod(mload(0x1300), mload(0x12a0), f_q))
mstore(0x1340, mulmod(mload(0x600), mload(0x180), f_q))
mstore(0x1360, addmod(mload(0xfa0), mload(0x1340), f_q))
mstore(0x1380, addmod(mload(0x1360), mload(0x1e0), f_q))
mstore(0x13a0, mulmod(mload(0x1380), mload(0x1320), f_q))
mstore(0x13c0, mulmod(mload(0x13a0), mload(0x640), f_q))
mstore(0x13e0, mulmod(1, mload(0x180), f_q))
mstore(0x1400, mulmod(mload(0x460), mload(0x13e0), f_q))
mstore(0x1420, addmod(mload(0x520), mload(0x1400), f_q))
mstore(0x1440, addmod(mload(0x1420), mload(0x1e0), f_q))
mstore(0x1460, mulmod(4131629893567559867359510883348571134090853742863529169391034518566172092834, mload(0x180), f_q))
mstore(0x1480, mulmod(mload(0x460), mload(0x1460), f_q))
mstore(0x14a0, addmod(mload(0x4a0), mload(0x1480), f_q))
mstore(0x14c0, addmod(mload(0x14a0), mload(0x1e0), f_q))
mstore(0x14e0, mulmod(mload(0x14c0), mload(0x1440), f_q))
mstore(0x1500, mulmod(8910878055287538404433155982483128285667088683464058436815641868457422632747, mload(0x180), f_q))
mstore(0x1520, mulmod(mload(0x460), mload(0x1500), f_q))
mstore(0x1540, addmod(mload(0xfa0), mload(0x1520), f_q))
mstore(0x1560, addmod(mload(0x1540), mload(0x1e0), f_q))
mstore(0x1580, mulmod(mload(0x1560), mload(0x14e0), f_q))
mstore(0x15a0, mulmod(mload(0x1580), mload(0x620), f_q))
mstore(0x15c0, addmod(mload(0x13c0), sub(f_q, mload(0x15a0)), f_q))
mstore(0x15e0, mulmod(mload(0x15c0), mload(0x1240), f_q))
mstore(0x1600, addmod(mload(0x1160), mload(0x15e0), f_q))
mstore(0x1620, mulmod(mload(0x300), mload(0x1600), f_q))
mstore(0x1640, addmod(1, sub(f_q, mload(0x660)), f_q))
mstore(0x1660, mulmod(mload(0x1640), mload(0xf80), f_q))
mstore(0x1680, addmod(mload(0x1620), mload(0x1660), f_q))
mstore(0x16a0, mulmod(mload(0x300), mload(0x1680), f_q))
mstore(0x16c0, mulmod(mload(0x660), mload(0x660), f_q))
mstore(0x16e0, addmod(mload(0x16c0), sub(f_q, mload(0x660)), f_q))
mstore(0x1700, mulmod(mload(0x16e0), mload(0xea0), f_q))
mstore(0x1720, addmod(mload(0x16a0), mload(0x1700), f_q))
mstore(0x1740, mulmod(mload(0x300), mload(0x1720), f_q))
mstore(0x1760, addmod(mload(0x6a0), mload(0x180), f_q))
mstore(0x1780, mulmod(mload(0x1760), mload(0x680), f_q))
mstore(0x17a0, addmod(mload(0x6e0), mload(0x1e0), f_q))
mstore(0x17c0, mulmod(mload(0x17a0), mload(0x1780), f_q))
mstore(0x17e0, mulmod(mload(0x4a0), mload(0x560), f_q))
mstore(0x1800, addmod(mload(0x17e0), mload(0x180), f_q))
mstore(0x1820, mulmod(mload(0x1800), mload(0x660), f_q))
mstore(0x1840, addmod(mload(0x540), mload(0x1e0), f_q))
mstore(0x1860, mulmod(mload(0x1840), mload(0x1820), f_q))
mstore(0x1880, addmod(mload(0x17c0), sub(f_q, mload(0x1860)), f_q))
mstore(0x18a0, mulmod(mload(0x1880), mload(0x1240), f_q))
mstore(0x18c0, addmod(mload(0x1740), mload(0x18a0), f_q))
mstore(0x18e0, mulmod(mload(0x300), mload(0x18c0), f_q))
mstore(0x1900, addmod(mload(0x6a0), sub(f_q, mload(0x6e0)), f_q))
mstore(0x1920, mulmod(mload(0x1900), mload(0xf80), f_q))
mstore(0x1940, addmod(mload(0x18e0), mload(0x1920), f_q))
mstore(0x1960, mulmod(mload(0x300), mload(0x1940), f_q))
mstore(0x1980, mulmod(mload(0x1900), mload(0x1240), f_q))
mstore(0x19a0, addmod(mload(0x6a0), sub(f_q, mload(0x6c0)), f_q))
mstore(0x19c0, mulmod(mload(0x19a0), mload(0x1980), f_q))
mstore(0x19e0, addmod(mload(0x1960), mload(0x19c0), f_q))
mstore(0x1a00, mulmod(mload(0xa60), mload(0xa60), f_q))
mstore(0x1a20, mulmod(mload(0x1a00), mload(0xa60), f_q))
mstore(0x1a40, mulmod(mload(0x1a20), mload(0xa60), f_q))
mstore(0x1a60, mulmod(1, mload(0xa60), f_q))
mstore(0x1a80, mulmod(1, mload(0x1a00), f_q))
mstore(0x1aa0, mulmod(1, mload(0x1a20), f_q))
mstore(0x1ac0, mulmod(mload(0x19e0), mload(0xa80), f_q))
mstore(0x1ae0, mulmod(mload(0x8a0), mload(0x460), f_q))
mstore(0x1b00, mulmod(mload(0x1ae0), mload(0x460), f_q))
mstore(0x1b20, mulmod(mload(0x460), 1, f_q))
mstore(0x1b40, addmod(mload(0x820), sub(f_q, mload(0x1b20)), f_q))
mstore(0x1b60, mulmod(mload(0x460), 14204982954615820785730815556166377574172276341958019443243371773666809943588, f_q))
mstore(0x1b80, addmod(mload(0x820), sub(f_q, mload(0x1b60)), f_q))
mstore(0x1ba0, mulmod(mload(0x460), 15929319040748925786993503352261583814540822795415523916919259682053529746604, f_q))
mstore(0x1bc0, addmod(mload(0x820), sub(f_q, mload(0x1ba0)), f_q))
mstore(0x1be0, mulmod(mload(0x460), 16835280225506959940941177652215257171979491230027470730380297510496806661123, f_q))
mstore(0x1c00, addmod(mload(0x820), sub(f_q, mload(0x1be0)), f_q))
mstore(0x1c20, mulmod(mload(0x460), 19671853614403325433334785013442879012032153960035114761748042217991436932142, f_q))
mstore(0x1c40, addmod(mload(0x820), sub(f_q, mload(0x1c20)), f_q))
{
            let result := mulmod(mload(0x820), mulmod(mload(0x1ae0), 10994196854230400248838994266177333528338096354733773870843333473624709641756, f_q), f_q)
result := addmod(mulmod(mload(0x460), mulmod(mload(0x1ae0), 10894046017608874973407411479079941560210268045682260472854870712951098853861, f_q), f_q), result, f_q)
mstore(7264, result)
        }
{
            let result := mulmod(mload(0x820), mulmod(mload(0x1ae0), 11744318328598495479041368798736869296678842604566191392625898663400189852562, f_q), f_q)
result := addmod(mulmod(mload(0x460), mulmod(mload(0x1ae0), 1630885607473158966786401726204007624847296365825470293226524573008041876560, f_q), f_q), result, f_q)
mstore(7296, result)
        }
{
            let result := mulmod(mload(0x820), mulmod(mload(0x1ae0), 1630885607473158966786401726204007624847296365825470293226524573008041876560, f_q), f_q)
result := addmod(mulmod(mload(0x460), mulmod(mload(0x1ae0), 11902471349048731598100411988238049155773179670986735492599691006318982376568, f_q), f_q), result, f_q)
mstore(7328, result)
        }
{
            let result := mulmod(mload(0x820), mulmod(mload(0x1ae0), 5182223787796982606412788884717687497934676283584874701630611751861787482408, f_q), f_q)
result := addmod(mulmod(mload(0x460), mulmod(mload(0x1ae0), 6528427606907041601188684379517237703958964656841261475841041978773459289184, f_q), f_q), result, f_q)
mstore(7360, result)
        }
mstore(0x1ce0, mulmod(1, mload(0x1b40), f_q))
mstore(0x1d00, mulmod(mload(0x1ce0), mload(0x1c40), f_q))
mstore(0x1d20, mulmod(mload(0x1d00), mload(0x1bc0), f_q))
mstore(0x1d40, mulmod(mload(0x1d20), mload(0x1c00), f_q))
{
            let result := mulmod(mload(0x820), mulmod(mload(0x460), 2216389257435949788911620731814396076516210440380919581950161968584371563476, f_q), f_q)
result := addmod(mulmod(mload(0x460), mulmod(mload(0x460), 19671853614403325433334785013442879012032153960035114761748042217991436932141, f_q), f_q), result, f_q)
mstore(7520, result)
        }
{
            let result := mulmod(mload(0x820), mulmod(mload(0x460), 19671853614403325433334785013442879012032153960035114761748042217991436932141, f_q), f_q)
result := addmod(mulmod(mload(0x460), mulmod(mload(0x460), 3742534573654399646341281661181295197491331164619590844828782535937907185538, f_q), f_q), result, f_q)
mstore(7552, result)
        }
{
            let result := mulmod(mload(0x820), mulmod(mload(0x460), 7683259917223454436515590189090897514376088058458014900454832412908998552030, f_q), f_q)
result := addmod(mulmod(mload(0x460), mulmod(mload(0x460), 14204982954615820785730815556166377574172276341958019443243371773666809943587, f_q), f_q), result, f_q)
mstore(7584, result)
        }
{
            let result := mulmod(mload(0x820), mulmod(mload(0x460), 14204982954615820785730815556166377574172276341958019443243371773666809943587, f_q), f_q)
result := addmod(mulmod(mload(0x460), mulmod(mload(0x460), 14558693512631580792465039609508383400844923965080603496144160823314055432360, f_q), f_q), result, f_q)
mstore(7616, result)
        }
mstore(0x1de0, mulmod(mload(0x1ce0), mload(0x1b80), f_q))
{
            let result := mulmod(mload(0x820), 1, f_q)
result := addmod(mulmod(mload(0x460), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q), result, f_q)
mstore(7680, result)
        }
{
            let prod := mload(0x1c60)

                prod := mulmod(mload(0x1c80), prod, f_q)
                mstore(0x1e20, prod)
            
                prod := mulmod(mload(0x1ca0), prod, f_q)
                mstore(0x1e40, prod)
            
                prod := mulmod(mload(0x1cc0), prod, f_q)
                mstore(0x1e60, prod)
            
                prod := mulmod(mload(0x1d60), prod, f_q)
                mstore(0x1e80, prod)
            
                prod := mulmod(mload(0x1d80), prod, f_q)
                mstore(0x1ea0, prod)
            
                prod := mulmod(mload(0x1d00), prod, f_q)
                mstore(0x1ec0, prod)
            
                prod := mulmod(mload(0x1da0), prod, f_q)
                mstore(0x1ee0, prod)
            
                prod := mulmod(mload(0x1dc0), prod, f_q)
                mstore(0x1f00, prod)
            
                prod := mulmod(mload(0x1de0), prod, f_q)
                mstore(0x1f20, prod)
            
                prod := mulmod(mload(0x1e00), prod, f_q)
                mstore(0x1f40, prod)
            
                prod := mulmod(mload(0x1ce0), prod, f_q)
                mstore(0x1f60, prod)
            
        }
mstore(0x1fa0, 32)
mstore(0x1fc0, 32)
mstore(0x1fe0, 32)
mstore(0x2000, mload(0x1f60))
mstore(0x2020, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
mstore(0x2040, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
success := and(eq(staticcall(gas(), 0x5, 0x1fa0, 0xc0, 0x1f80, 0x20), 1), success)
{
            
            let inv := mload(0x1f80)
            let v
        
                    v := mload(0x1ce0)
                    mstore(7392, mulmod(mload(0x1f40), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1e00)
                    mstore(7680, mulmod(mload(0x1f20), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1de0)
                    mstore(7648, mulmod(mload(0x1f00), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1dc0)
                    mstore(7616, mulmod(mload(0x1ee0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1da0)
                    mstore(7584, mulmod(mload(0x1ec0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1d00)
                    mstore(7424, mulmod(mload(0x1ea0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1d80)
                    mstore(7552, mulmod(mload(0x1e80), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1d60)
                    mstore(7520, mulmod(mload(0x1e60), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1cc0)
                    mstore(7360, mulmod(mload(0x1e40), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1ca0)
                    mstore(7328, mulmod(mload(0x1e20), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1c80)
                    mstore(7296, mulmod(mload(0x1c60), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                mstore(0x1c60, inv)

        }
{
            let result := mload(0x1c60)
result := addmod(mload(0x1c80), result, f_q)
result := addmod(mload(0x1ca0), result, f_q)
result := addmod(mload(0x1cc0), result, f_q)
mstore(8288, result)
        }
mstore(0x2080, mulmod(mload(0x1d40), mload(0x1d00), f_q))
{
            let result := mload(0x1d60)
result := addmod(mload(0x1d80), result, f_q)
mstore(8352, result)
        }
mstore(0x20c0, mulmod(mload(0x1d40), mload(0x1de0), f_q))
{
            let result := mload(0x1da0)
result := addmod(mload(0x1dc0), result, f_q)
mstore(8416, result)
        }
mstore(0x2100, mulmod(mload(0x1d40), mload(0x1ce0), f_q))
{
            let result := mload(0x1e00)
mstore(8480, result)
        }
{
            let prod := mload(0x2060)

                prod := mulmod(mload(0x20a0), prod, f_q)
                mstore(0x2140, prod)
            
                prod := mulmod(mload(0x20e0), prod, f_q)
                mstore(0x2160, prod)
            
                prod := mulmod(mload(0x2120), prod, f_q)
                mstore(0x2180, prod)
            
        }
mstore(0x21c0, 32)
mstore(0x21e0, 32)
mstore(0x2200, 32)
mstore(0x2220, mload(0x2180))
mstore(0x2240, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
mstore(0x2260, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
success := and(eq(staticcall(gas(), 0x5, 0x21c0, 0xc0, 0x21a0, 0x20), 1), success)
{
            
            let inv := mload(0x21a0)
            let v
        
                    v := mload(0x2120)
                    mstore(8480, mulmod(mload(0x2160), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x20e0)
                    mstore(8416, mulmod(mload(0x2140), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x20a0)
                    mstore(8352, mulmod(mload(0x2060), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                mstore(0x2060, inv)

        }
mstore(0x2280, mulmod(mload(0x2080), mload(0x20a0), f_q))
mstore(0x22a0, mulmod(mload(0x20c0), mload(0x20e0), f_q))
mstore(0x22c0, mulmod(mload(0x2100), mload(0x2120), f_q))
mstore(0x22e0, mulmod(mload(0x720), mload(0x720), f_q))
mstore(0x2300, mulmod(mload(0x22e0), mload(0x720), f_q))
mstore(0x2320, mulmod(mload(0x2300), mload(0x720), f_q))
mstore(0x2340, mulmod(mload(0x2320), mload(0x720), f_q))
mstore(0x2360, mulmod(mload(0x2340), mload(0x720), f_q))
mstore(0x2380, mulmod(mload(0x2360), mload(0x720), f_q))
mstore(0x23a0, mulmod(mload(0x2380), mload(0x720), f_q))
mstore(0x23c0, mulmod(mload(0x23a0), mload(0x720), f_q))
mstore(0x23e0, mulmod(mload(0x23c0), mload(0x720), f_q))
mstore(0x2400, mulmod(mload(0x780), mload(0x780), f_q))
mstore(0x2420, mulmod(mload(0x2400), mload(0x780), f_q))
mstore(0x2440, mulmod(mload(0x2420), mload(0x780), f_q))
{
            let result := mulmod(mload(0x4a0), mload(0x1c60), f_q)
result := addmod(mulmod(mload(0x4c0), mload(0x1c80), f_q), result, f_q)
result := addmod(mulmod(mload(0x4e0), mload(0x1ca0), f_q), result, f_q)
result := addmod(mulmod(mload(0x500), mload(0x1cc0), f_q), result, f_q)
mstore(9312, result)
        }
mstore(0x2480, mulmod(mload(0x2460), mload(0x2060), f_q))
mstore(0x24a0, mulmod(sub(f_q, mload(0x2480)), 1, f_q))
mstore(0x24c0, mulmod(mload(0x24a0), 1, f_q))
mstore(0x24e0, mulmod(1, mload(0x2080), f_q))
{
            let result := mulmod(mload(0x620), mload(0x1d60), f_q)
result := addmod(mulmod(mload(0x640), mload(0x1d80), f_q), result, f_q)
mstore(9472, result)
        }
mstore(0x2520, mulmod(mload(0x2500), mload(0x2280), f_q))
mstore(0x2540, mulmod(sub(f_q, mload(0x2520)), 1, f_q))
mstore(0x2560, mulmod(mload(0x24e0), 1, f_q))
{
            let result := mulmod(mload(0x660), mload(0x1d60), f_q)
result := addmod(mulmod(mload(0x680), mload(0x1d80), f_q), result, f_q)
mstore(9600, result)
        }
mstore(0x25a0, mulmod(mload(0x2580), mload(0x2280), f_q))
mstore(0x25c0, mulmod(sub(f_q, mload(0x25a0)), mload(0x720), f_q))
mstore(0x25e0, mulmod(mload(0x24e0), mload(0x720), f_q))
mstore(0x2600, addmod(mload(0x2540), mload(0x25c0), f_q))
mstore(0x2620, mulmod(mload(0x2600), mload(0x780), f_q))
mstore(0x2640, mulmod(mload(0x2560), mload(0x780), f_q))
mstore(0x2660, mulmod(mload(0x25e0), mload(0x780), f_q))
mstore(0x2680, addmod(mload(0x24c0), mload(0x2620), f_q))
mstore(0x26a0, mulmod(1, mload(0x20c0), f_q))
{
            let result := mulmod(mload(0x6a0), mload(0x1da0), f_q)
result := addmod(mulmod(mload(0x6c0), mload(0x1dc0), f_q), result, f_q)
mstore(9920, result)
        }
mstore(0x26e0, mulmod(mload(0x26c0), mload(0x22a0), f_q))
mstore(0x2700, mulmod(sub(f_q, mload(0x26e0)), 1, f_q))
mstore(0x2720, mulmod(mload(0x26a0), 1, f_q))
mstore(0x2740, mulmod(mload(0x2700), mload(0x2400), f_q))
mstore(0x2760, mulmod(mload(0x2720), mload(0x2400), f_q))
mstore(0x2780, addmod(mload(0x2680), mload(0x2740), f_q))
mstore(0x27a0, mulmod(1, mload(0x2100), f_q))
{
            let result := mulmod(mload(0x6e0), mload(0x1e00), f_q)
mstore(10176, result)
        }
mstore(0x27e0, mulmod(mload(0x27c0), mload(0x22c0), f_q))
mstore(0x2800, mulmod(sub(f_q, mload(0x27e0)), 1, f_q))
mstore(0x2820, mulmod(mload(0x27a0), 1, f_q))
{
            let result := mulmod(mload(0x520), mload(0x1e00), f_q)
mstore(10304, result)
        }
mstore(0x2860, mulmod(mload(0x2840), mload(0x22c0), f_q))
mstore(0x2880, mulmod(sub(f_q, mload(0x2860)), mload(0x720), f_q))
mstore(0x28a0, mulmod(mload(0x27a0), mload(0x720), f_q))
mstore(0x28c0, addmod(mload(0x2800), mload(0x2880), f_q))
{
            let result := mulmod(mload(0x540), mload(0x1e00), f_q)
mstore(10464, result)
        }
mstore(0x2900, mulmod(mload(0x28e0), mload(0x22c0), f_q))
mstore(0x2920, mulmod(sub(f_q, mload(0x2900)), mload(0x22e0), f_q))
mstore(0x2940, mulmod(mload(0x27a0), mload(0x22e0), f_q))
mstore(0x2960, addmod(mload(0x28c0), mload(0x2920), f_q))
{
            let result := mulmod(mload(0x560), mload(0x1e00), f_q)
mstore(10624, result)
        }
mstore(0x29a0, mulmod(mload(0x2980), mload(0x22c0), f_q))
mstore(0x29c0, mulmod(sub(f_q, mload(0x29a0)), mload(0x2300), f_q))
mstore(0x29e0, mulmod(mload(0x27a0), mload(0x2300), f_q))
mstore(0x2a00, addmod(mload(0x2960), mload(0x29c0), f_q))
{
            let result := mulmod(mload(0x580), mload(0x1e00), f_q)
mstore(10784, result)
        }
mstore(0x2a40, mulmod(mload(0x2a20), mload(0x22c0), f_q))
mstore(0x2a60, mulmod(sub(f_q, mload(0x2a40)), mload(0x2320), f_q))
mstore(0x2a80, mulmod(mload(0x27a0), mload(0x2320), f_q))
mstore(0x2aa0, addmod(mload(0x2a00), mload(0x2a60), f_q))
{
            let result := mulmod(mload(0x5c0), mload(0x1e00), f_q)
mstore(10944, result)
        }
mstore(0x2ae0, mulmod(mload(0x2ac0), mload(0x22c0), f_q))
mstore(0x2b00, mulmod(sub(f_q, mload(0x2ae0)), mload(0x2340), f_q))
mstore(0x2b20, mulmod(mload(0x27a0), mload(0x2340), f_q))
mstore(0x2b40, addmod(mload(0x2aa0), mload(0x2b00), f_q))
{
            let result := mulmod(mload(0x5e0), mload(0x1e00), f_q)
mstore(11104, result)
        }
mstore(0x2b80, mulmod(mload(0x2b60), mload(0x22c0), f_q))
mstore(0x2ba0, mulmod(sub(f_q, mload(0x2b80)), mload(0x2360), f_q))
mstore(0x2bc0, mulmod(mload(0x27a0), mload(0x2360), f_q))
mstore(0x2be0, addmod(mload(0x2b40), mload(0x2ba0), f_q))
{
            let result := mulmod(mload(0x600), mload(0x1e00), f_q)
mstore(11264, result)
        }
mstore(0x2c20, mulmod(mload(0x2c00), mload(0x22c0), f_q))
mstore(0x2c40, mulmod(sub(f_q, mload(0x2c20)), mload(0x2380), f_q))
mstore(0x2c60, mulmod(mload(0x27a0), mload(0x2380), f_q))
mstore(0x2c80, addmod(mload(0x2be0), mload(0x2c40), f_q))
mstore(0x2ca0, mulmod(mload(0x1a60), mload(0x2100), f_q))
mstore(0x2cc0, mulmod(mload(0x1a80), mload(0x2100), f_q))
mstore(0x2ce0, mulmod(mload(0x1aa0), mload(0x2100), f_q))
{
            let result := mulmod(mload(0x1ac0), mload(0x1e00), f_q)
mstore(11520, result)
        }
mstore(0x2d20, mulmod(mload(0x2d00), mload(0x22c0), f_q))
mstore(0x2d40, mulmod(sub(f_q, mload(0x2d20)), mload(0x23a0), f_q))
mstore(0x2d60, mulmod(mload(0x27a0), mload(0x23a0), f_q))
mstore(0x2d80, mulmod(mload(0x2ca0), mload(0x23a0), f_q))
mstore(0x2da0, mulmod(mload(0x2cc0), mload(0x23a0), f_q))
mstore(0x2dc0, mulmod(mload(0x2ce0), mload(0x23a0), f_q))
mstore(0x2de0, addmod(mload(0x2c80), mload(0x2d40), f_q))
{
            let result := mulmod(mload(0x5a0), mload(0x1e00), f_q)
mstore(11776, result)
        }
mstore(0x2e20, mulmod(mload(0x2e00), mload(0x22c0), f_q))
mstore(0x2e40, mulmod(sub(f_q, mload(0x2e20)), mload(0x23c0), f_q))
mstore(0x2e60, mulmod(mload(0x27a0), mload(0x23c0), f_q))
mstore(0x2e80, addmod(mload(0x2de0), mload(0x2e40), f_q))
mstore(0x2ea0, mulmod(mload(0x2e80), mload(0x2420), f_q))
mstore(0x2ec0, mulmod(mload(0x2820), mload(0x2420), f_q))
mstore(0x2ee0, mulmod(mload(0x28a0), mload(0x2420), f_q))
mstore(0x2f00, mulmod(mload(0x2940), mload(0x2420), f_q))
mstore(0x2f20, mulmod(mload(0x29e0), mload(0x2420), f_q))
mstore(0x2f40, mulmod(mload(0x2a80), mload(0x2420), f_q))
mstore(0x2f60, mulmod(mload(0x2b20), mload(0x2420), f_q))
mstore(0x2f80, mulmod(mload(0x2bc0), mload(0x2420), f_q))
mstore(0x2fa0, mulmod(mload(0x2c60), mload(0x2420), f_q))
mstore(0x2fc0, mulmod(mload(0x2d60), mload(0x2420), f_q))
mstore(0x2fe0, mulmod(mload(0x2d80), mload(0x2420), f_q))
mstore(0x3000, mulmod(mload(0x2da0), mload(0x2420), f_q))
mstore(0x3020, mulmod(mload(0x2dc0), mload(0x2420), f_q))
mstore(0x3040, mulmod(mload(0x2e60), mload(0x2420), f_q))
mstore(0x3060, addmod(mload(0x2780), mload(0x2ea0), f_q))
mstore(0x3080, mulmod(1, mload(0x1d40), f_q))
mstore(0x30a0, mulmod(1, mload(0x820), f_q))
mstore(0x30c0, 0x0000000000000000000000000000000000000000000000000000000000000001)
                    mstore(0x30e0, 0x0000000000000000000000000000000000000000000000000000000000000002)
mstore(0x3100, mload(0x3060))
success := and(eq(staticcall(gas(), 0x7, 0x30c0, 0x60, 0x30c0, 0x40), 1), success)
mstore(0x3120, mload(0x30c0))
                    mstore(0x3140, mload(0x30e0))
mstore(0x3160, mload(0x40))
                    mstore(0x3180, mload(0x60))
success := and(eq(staticcall(gas(), 0x6, 0x3120, 0x80, 0x3120, 0x40), 1), success)
mstore(0x31a0, mload(0x220))
                    mstore(0x31c0, mload(0x240))
mstore(0x31e0, mload(0x2640))
success := and(eq(staticcall(gas(), 0x7, 0x31a0, 0x60, 0x31a0, 0x40), 1), success)
mstore(0x3200, mload(0x3120))
                    mstore(0x3220, mload(0x3140))
mstore(0x3240, mload(0x31a0))
                    mstore(0x3260, mload(0x31c0))
success := and(eq(staticcall(gas(), 0x6, 0x3200, 0x80, 0x3200, 0x40), 1), success)
mstore(0x3280, mload(0x260))
                    mstore(0x32a0, mload(0x280))
mstore(0x32c0, mload(0x2660))
success := and(eq(staticcall(gas(), 0x7, 0x3280, 0x60, 0x3280, 0x40), 1), success)
mstore(0x32e0, mload(0x3200))
                    mstore(0x3300, mload(0x3220))
mstore(0x3320, mload(0x3280))
                    mstore(0x3340, mload(0x32a0))
success := and(eq(staticcall(gas(), 0x6, 0x32e0, 0x80, 0x32e0, 0x40), 1), success)
mstore(0x3360, mload(0xe0))
                    mstore(0x3380, mload(0x100))
mstore(0x33a0, mload(0x2760))
success := and(eq(staticcall(gas(), 0x7, 0x3360, 0x60, 0x3360, 0x40), 1), success)
mstore(0x33c0, mload(0x32e0))
                    mstore(0x33e0, mload(0x3300))
mstore(0x3400, mload(0x3360))
                    mstore(0x3420, mload(0x3380))
success := and(eq(staticcall(gas(), 0x6, 0x33c0, 0x80, 0x33c0, 0x40), 1), success)
mstore(0x3440, mload(0x120))
                    mstore(0x3460, mload(0x140))
mstore(0x3480, mload(0x2ec0))
success := and(eq(staticcall(gas(), 0x7, 0x3440, 0x60, 0x3440, 0x40), 1), success)
mstore(0x34a0, mload(0x33c0))
                    mstore(0x34c0, mload(0x33e0))
mstore(0x34e0, mload(0x3440))
                    mstore(0x3500, mload(0x3460))
success := and(eq(staticcall(gas(), 0x6, 0x34a0, 0x80, 0x34a0, 0x40), 1), success)
mstore(0x3520, 0x24fcb291acdaf6422dcf156eb97d23121e5a772101c829d8d3afdba0e38ff6ac)
                    mstore(0x3540, 0x1d622003b2cd0bd481850ef67fd9073f4a1d86d2bb056cb7444fea868b9635df)
mstore(0x3560, mload(0x2ee0))
success := and(eq(staticcall(gas(), 0x7, 0x3520, 0x60, 0x3520, 0x40), 1), success)
mstore(0x3580, mload(0x34a0))
                    mstore(0x35a0, mload(0x34c0))
mstore(0x35c0, mload(0x3520))
                    mstore(0x35e0, mload(0x3540))
success := and(eq(staticcall(gas(), 0x6, 0x3580, 0x80, 0x3580, 0x40), 1), success)
mstore(0x3600, 0x1a01290b3442ca346a9f4fc35ab974ae7e7bcd0e7f5b047c693c09847201c538)
                    mstore(0x3620, 0x1fad77828508076665623e3bcf79b31f883fa9bb14cfc8f28eb600bb6f7109c8)
mstore(0x3640, mload(0x2f00))
success := and(eq(staticcall(gas(), 0x7, 0x3600, 0x60, 0x3600, 0x40), 1), success)
mstore(0x3660, mload(0x3580))
                    mstore(0x3680, mload(0x35a0))
mstore(0x36a0, mload(0x3600))
                    mstore(0x36c0, mload(0x3620))
success := and(eq(staticcall(gas(), 0x6, 0x3660, 0x80, 0x3660, 0x40), 1), success)
mstore(0x36e0, 0x198cf6ddba34ca4087d743b5ccc027baf31dc9c43f454ed64f3043d6f97ed5a7)
                    mstore(0x3700, 0x23cf4e169893d322b9d76beea0bc1a014ba1a99413b81d8d1a6a535a127afe5d)
mstore(0x3720, mload(0x2f20))
success := and(eq(staticcall(gas(), 0x7, 0x36e0, 0x60, 0x36e0, 0x40), 1), success)
mstore(0x3740, mload(0x3660))
                    mstore(0x3760, mload(0x3680))
mstore(0x3780, mload(0x36e0))
                    mstore(0x37a0, mload(0x3700))
success := and(eq(staticcall(gas(), 0x6, 0x3740, 0x80, 0x3740, 0x40), 1), success)
mstore(0x37c0, 0x2bf6a4b1d5975b81f0c218aea8aaf432939042706d00b9e28e11786a66d7f4c0)
                    mstore(0x37e0, 0x2d28b347b9be96250655dee0fd47f5c7ad2b1f4f479b2777fad20ff2dbc3030a)
mstore(0x3800, mload(0x2f40))
success := and(eq(staticcall(gas(), 0x7, 0x37c0, 0x60, 0x37c0, 0x40), 1), success)
mstore(0x3820, mload(0x3740))
                    mstore(0x3840, mload(0x3760))
mstore(0x3860, mload(0x37c0))
                    mstore(0x3880, mload(0x37e0))
success := and(eq(staticcall(gas(), 0x6, 0x3820, 0x80, 0x3820, 0x40), 1), success)
mstore(0x38a0, 0x1e3ebfed75a03b30ee0e91db362a5ec02e53ea9af3510b36036c9a1d0e9811be)
                    mstore(0x38c0, 0x1babfe3bc2b323de8d07adfc7b94122fb63adda1f87ad9cb00cda33c0bfbadaa)
mstore(0x38e0, mload(0x2f60))
success := and(eq(staticcall(gas(), 0x7, 0x38a0, 0x60, 0x38a0, 0x40), 1), success)
mstore(0x3900, mload(0x3820))
                    mstore(0x3920, mload(0x3840))
mstore(0x3940, mload(0x38a0))
                    mstore(0x3960, mload(0x38c0))
success := and(eq(staticcall(gas(), 0x6, 0x3900, 0x80, 0x3900, 0x40), 1), success)
mstore(0x3980, 0x290ab6911d8524802c7dbd2083177a1cac597692294db4e49f8f6d506c64bb2b)
                    mstore(0x39a0, 0x2855af0001e552769ef25adffde1a0198ef5238f1bd822a052260c360b583fab)
mstore(0x39c0, mload(0x2f80))
success := and(eq(staticcall(gas(), 0x7, 0x3980, 0x60, 0x3980, 0x40), 1), success)
mstore(0x39e0, mload(0x3900))
                    mstore(0x3a00, mload(0x3920))
mstore(0x3a20, mload(0x3980))
                    mstore(0x3a40, mload(0x39a0))
success := and(eq(staticcall(gas(), 0x6, 0x39e0, 0x80, 0x39e0, 0x40), 1), success)
mstore(0x3a60, 0x2858f36c2f4d67d8a310304bda98930aa99a4846990781b59821f98a5ac4f214)
                    mstore(0x3a80, 0x15a55ffb821a9f068fcb3ba85caba4e500d31d96ac15fc0146051ba30eeb4c45)
mstore(0x3aa0, mload(0x2fa0))
success := and(eq(staticcall(gas(), 0x7, 0x3a60, 0x60, 0x3a60, 0x40), 1), success)
mstore(0x3ac0, mload(0x39e0))
                    mstore(0x3ae0, mload(0x3a00))
mstore(0x3b00, mload(0x3a60))
                    mstore(0x3b20, mload(0x3a80))
success := and(eq(staticcall(gas(), 0x6, 0x3ac0, 0x80, 0x3ac0, 0x40), 1), success)
mstore(0x3b40, mload(0x340))
                    mstore(0x3b60, mload(0x360))
mstore(0x3b80, mload(0x2fc0))
success := and(eq(staticcall(gas(), 0x7, 0x3b40, 0x60, 0x3b40, 0x40), 1), success)
mstore(0x3ba0, mload(0x3ac0))
                    mstore(0x3bc0, mload(0x3ae0))
mstore(0x3be0, mload(0x3b40))
                    mstore(0x3c00, mload(0x3b60))
success := and(eq(staticcall(gas(), 0x6, 0x3ba0, 0x80, 0x3ba0, 0x40), 1), success)
mstore(0x3c20, mload(0x380))
                    mstore(0x3c40, mload(0x3a0))
mstore(0x3c60, mload(0x2fe0))
success := and(eq(staticcall(gas(), 0x7, 0x3c20, 0x60, 0x3c20, 0x40), 1), success)
mstore(0x3c80, mload(0x3ba0))
                    mstore(0x3ca0, mload(0x3bc0))
mstore(0x3cc0, mload(0x3c20))
                    mstore(0x3ce0, mload(0x3c40))
success := and(eq(staticcall(gas(), 0x6, 0x3c80, 0x80, 0x3c80, 0x40), 1), success)
mstore(0x3d00, mload(0x3c0))
                    mstore(0x3d20, mload(0x3e0))
mstore(0x3d40, mload(0x3000))
success := and(eq(staticcall(gas(), 0x7, 0x3d00, 0x60, 0x3d00, 0x40), 1), success)
mstore(0x3d60, mload(0x3c80))
                    mstore(0x3d80, mload(0x3ca0))
mstore(0x3da0, mload(0x3d00))
                    mstore(0x3dc0, mload(0x3d20))
success := and(eq(staticcall(gas(), 0x6, 0x3d60, 0x80, 0x3d60, 0x40), 1), success)
mstore(0x3de0, mload(0x400))
                    mstore(0x3e00, mload(0x420))
mstore(0x3e20, mload(0x3020))
success := and(eq(staticcall(gas(), 0x7, 0x3de0, 0x60, 0x3de0, 0x40), 1), success)
mstore(0x3e40, mload(0x3d60))
                    mstore(0x3e60, mload(0x3d80))
mstore(0x3e80, mload(0x3de0))
                    mstore(0x3ea0, mload(0x3e00))
success := and(eq(staticcall(gas(), 0x6, 0x3e40, 0x80, 0x3e40, 0x40), 1), success)
mstore(0x3ec0, mload(0x2a0))
                    mstore(0x3ee0, mload(0x2c0))
mstore(0x3f00, mload(0x3040))
success := and(eq(staticcall(gas(), 0x7, 0x3ec0, 0x60, 0x3ec0, 0x40), 1), success)
mstore(0x3f20, mload(0x3e40))
                    mstore(0x3f40, mload(0x3e60))
mstore(0x3f60, mload(0x3ec0))
                    mstore(0x3f80, mload(0x3ee0))
success := and(eq(staticcall(gas(), 0x6, 0x3f20, 0x80, 0x3f20, 0x40), 1), success)
mstore(0x3fa0, mload(0x7c0))
                    mstore(0x3fc0, mload(0x7e0))
mstore(0x3fe0, sub(f_q, mload(0x3080)))
success := and(eq(staticcall(gas(), 0x7, 0x3fa0, 0x60, 0x3fa0, 0x40), 1), success)
mstore(0x4000, mload(0x3f20))
                    mstore(0x4020, mload(0x3f40))
mstore(0x4040, mload(0x3fa0))
                    mstore(0x4060, mload(0x3fc0))
success := and(eq(staticcall(gas(), 0x6, 0x4000, 0x80, 0x4000, 0x40), 1), success)
mstore(0x4080, mload(0x860))
                    mstore(0x40a0, mload(0x880))
mstore(0x40c0, mload(0x30a0))
success := and(eq(staticcall(gas(), 0x7, 0x4080, 0x60, 0x4080, 0x40), 1), success)
mstore(0x40e0, mload(0x4000))
                    mstore(0x4100, mload(0x4020))
mstore(0x4120, mload(0x4080))
                    mstore(0x4140, mload(0x40a0))
success := and(eq(staticcall(gas(), 0x6, 0x40e0, 0x80, 0x40e0, 0x40), 1), success)
mstore(0x4160, mload(0x40e0))
                    mstore(0x4180, mload(0x4100))
mstore(0x41a0, 0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2)
            mstore(0x41c0, 0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed)
            mstore(0x41e0, 0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b)
            mstore(0x4200, 0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa)
mstore(0x4220, mload(0x860))
                    mstore(0x4240, mload(0x880))
mstore(0x4260, 0x0181624e80f3d6ae28df7e01eaeab1c0e919877a3b8a6b7fbc69a6817d596ea2)
            mstore(0x4280, 0x1783d30dcb12d259bb89098addf6280fa4b653be7a152542a28f7b926e27e648)
            mstore(0x42a0, 0x00ae44489d41a0d179e2dfdc03bddd883b7109f8b6ae316a59e815c1a6b35304)
            mstore(0x42c0, 0x0b2147ab62a386bd63e6de1522109b8c9588ab466f5aadfde8c41ca3749423ee)
success := and(eq(staticcall(gas(), 0x8, 0x4160, 0x180, 0x4160, 0x20), 1), success)
success := and(eq(mload(0x4160), 1), success)

            if not(success) { revert(0, 0) }
            return(0, 0)

                }
            }
        }