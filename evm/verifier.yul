
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
mstore(0x0, 18293073342275164720908597273197389830330211108779440611401589627366875675319)

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
mstore(0xa80, mulmod(mload(0xa60), mload(0xa60), f_q))
mstore(0xaa0, addmod(mload(0xa80), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q))
mstore(0xac0, mulmod(mload(0xaa0), 21887908883758345057524386604544609419677994704914319011142910940051965480961, f_q))
mstore(0xae0, mulmod(mload(0xac0), 19343146892916237615654043009195602139873661276405922646774320324892220692243, f_q))
mstore(0xb00, addmod(mload(0x460), 2545095978923037606592362736061672948674703124010111696923883861683587803374, f_q))
mstore(0xb20, mulmod(mload(0xac0), 10763352634187770026454006562738618997775638622944072507352459644433398105234, f_q))
mstore(0xb40, addmod(mload(0x460), 11124890237651505195792399182518656090772725777471961836345744542142410390383, f_q))
mstore(0xb60, mulmod(mload(0xac0), 20628911774076080115677997654955975916574240699700602202492084084217515773353, f_q))
mstore(0xb80, addmod(mload(0x460), 1259331097763195106568408090301299171974123700715432141206120102358292722264, f_q))
mstore(0xba0, mulmod(mload(0xac0), 21534532313823515215512181691915269261875716777293450290797415136928563006845, f_q))
mstore(0xbc0, addmod(mload(0x460), 353710558015760006734224053342005826672647623122584052900789049647245488772, f_q))
mstore(0xbe0, mulmod(mload(0xac0), 18801136258871406524726641978934912926273987048785013233465874845411408769764, f_q))
mstore(0xc00, addmod(mload(0x460), 3087106612967868697519763766322362162274377351631021110232329341164399725853, f_q))
mstore(0xc20, mulmod(mload(0xac0), 14204982954615820785730815556166377574172276341958019443243371773666809943588, f_q))
mstore(0xc40, addmod(mload(0x460), 7683259917223454436515590189090897514376088058458014900454832412908998552029, f_q))
mstore(0xc60, mulmod(mload(0xac0), 5857228514216831962358810454360739186987616060007133076514874820078026801648, f_q))
mstore(0xc80, addmod(mload(0x460), 16031014357622443259887595290896535901560748340408901267183329366497781693969, f_q))
mstore(0xca0, mulmod(mload(0xac0), 1, f_q))
mstore(0xcc0, addmod(mload(0x460), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q))
{
            let prod := mload(0xb00)

                prod := mulmod(mload(0xb40), prod, f_q)
                mstore(0xce0, prod)
            
                prod := mulmod(mload(0xb80), prod, f_q)
                mstore(0xd00, prod)
            
                prod := mulmod(mload(0xbc0), prod, f_q)
                mstore(0xd20, prod)
            
                prod := mulmod(mload(0xc00), prod, f_q)
                mstore(0xd40, prod)
            
                prod := mulmod(mload(0xc40), prod, f_q)
                mstore(0xd60, prod)
            
                prod := mulmod(mload(0xc80), prod, f_q)
                mstore(0xd80, prod)
            
                prod := mulmod(mload(0xcc0), prod, f_q)
                mstore(0xda0, prod)
            
                prod := mulmod(mload(0xaa0), prod, f_q)
                mstore(0xdc0, prod)
            
        }
mstore(0xe00, 32)
mstore(0xe20, 32)
mstore(0xe40, 32)
mstore(0xe60, mload(0xdc0))
mstore(0xe80, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
mstore(0xea0, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
success := and(eq(staticcall(gas(), 0x5, 0xe00, 0xc0, 0xde0, 0x20), 1), success)
{
            
            let inv := mload(0xde0)
            let v
        
                    v := mload(0xaa0)
                    mstore(2720, mulmod(mload(0xda0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xcc0)
                    mstore(3264, mulmod(mload(0xd80), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xc80)
                    mstore(3200, mulmod(mload(0xd60), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xc40)
                    mstore(3136, mulmod(mload(0xd40), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xc00)
                    mstore(3072, mulmod(mload(0xd20), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xbc0)
                    mstore(3008, mulmod(mload(0xd00), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xb80)
                    mstore(2944, mulmod(mload(0xce0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0xb40)
                    mstore(2880, mulmod(mload(0xb00), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                mstore(0xb00, inv)

        }
mstore(0xec0, mulmod(mload(0xae0), mload(0xb00), f_q))
mstore(0xee0, mulmod(mload(0xb20), mload(0xb40), f_q))
mstore(0xf00, mulmod(mload(0xb60), mload(0xb80), f_q))
mstore(0xf20, mulmod(mload(0xba0), mload(0xbc0), f_q))
mstore(0xf40, mulmod(mload(0xbe0), mload(0xc00), f_q))
mstore(0xf60, mulmod(mload(0xc20), mload(0xc40), f_q))
mstore(0xf80, mulmod(mload(0xc60), mload(0xc80), f_q))
mstore(0xfa0, mulmod(mload(0xca0), mload(0xcc0), f_q))
{
            let result := mulmod(mload(0xfa0), mload(0x20), f_q)
mstore(4032, result)
        }
mstore(0xfe0, mulmod(mload(0x4e0), mload(0x4c0), f_q))
mstore(0x1000, addmod(mload(0x4a0), mload(0xfe0), f_q))
mstore(0x1020, addmod(mload(0x1000), sub(f_q, mload(0x500)), f_q))
mstore(0x1040, mulmod(mload(0x1020), mload(0x580), f_q))
mstore(0x1060, mulmod(mload(0x300), mload(0x1040), f_q))
mstore(0x1080, addmod(1, sub(f_q, mload(0x620)), f_q))
mstore(0x10a0, mulmod(mload(0x1080), mload(0xfa0), f_q))
mstore(0x10c0, addmod(mload(0x1060), mload(0x10a0), f_q))
mstore(0x10e0, mulmod(mload(0x300), mload(0x10c0), f_q))
mstore(0x1100, mulmod(mload(0x620), mload(0x620), f_q))
mstore(0x1120, addmod(mload(0x1100), sub(f_q, mload(0x620)), f_q))
mstore(0x1140, mulmod(mload(0x1120), mload(0xec0), f_q))
mstore(0x1160, addmod(mload(0x10e0), mload(0x1140), f_q))
mstore(0x1180, mulmod(mload(0x300), mload(0x1160), f_q))
mstore(0x11a0, addmod(1, sub(f_q, mload(0xec0)), f_q))
mstore(0x11c0, addmod(mload(0xee0), mload(0xf00), f_q))
mstore(0x11e0, addmod(mload(0x11c0), mload(0xf20), f_q))
mstore(0x1200, addmod(mload(0x11e0), mload(0xf40), f_q))
mstore(0x1220, addmod(mload(0x1200), mload(0xf60), f_q))
mstore(0x1240, addmod(mload(0x1220), mload(0xf80), f_q))
mstore(0x1260, addmod(mload(0x11a0), sub(f_q, mload(0x1240)), f_q))
mstore(0x1280, mulmod(mload(0x5c0), mload(0x180), f_q))
mstore(0x12a0, addmod(mload(0x520), mload(0x1280), f_q))
mstore(0x12c0, addmod(mload(0x12a0), mload(0x1e0), f_q))
mstore(0x12e0, mulmod(mload(0x5e0), mload(0x180), f_q))
mstore(0x1300, addmod(mload(0x4a0), mload(0x12e0), f_q))
mstore(0x1320, addmod(mload(0x1300), mload(0x1e0), f_q))
mstore(0x1340, mulmod(mload(0x1320), mload(0x12c0), f_q))
mstore(0x1360, mulmod(mload(0x600), mload(0x180), f_q))
mstore(0x1380, addmod(mload(0xfc0), mload(0x1360), f_q))
mstore(0x13a0, addmod(mload(0x1380), mload(0x1e0), f_q))
mstore(0x13c0, mulmod(mload(0x13a0), mload(0x1340), f_q))
mstore(0x13e0, mulmod(mload(0x13c0), mload(0x640), f_q))
mstore(0x1400, mulmod(1, mload(0x180), f_q))
mstore(0x1420, mulmod(mload(0x460), mload(0x1400), f_q))
mstore(0x1440, addmod(mload(0x520), mload(0x1420), f_q))
mstore(0x1460, addmod(mload(0x1440), mload(0x1e0), f_q))
mstore(0x1480, mulmod(4131629893567559867359510883348571134090853742863529169391034518566172092834, mload(0x180), f_q))
mstore(0x14a0, mulmod(mload(0x460), mload(0x1480), f_q))
mstore(0x14c0, addmod(mload(0x4a0), mload(0x14a0), f_q))
mstore(0x14e0, addmod(mload(0x14c0), mload(0x1e0), f_q))
mstore(0x1500, mulmod(mload(0x14e0), mload(0x1460), f_q))
mstore(0x1520, mulmod(8910878055287538404433155982483128285667088683464058436815641868457422632747, mload(0x180), f_q))
mstore(0x1540, mulmod(mload(0x460), mload(0x1520), f_q))
mstore(0x1560, addmod(mload(0xfc0), mload(0x1540), f_q))
mstore(0x1580, addmod(mload(0x1560), mload(0x1e0), f_q))
mstore(0x15a0, mulmod(mload(0x1580), mload(0x1500), f_q))
mstore(0x15c0, mulmod(mload(0x15a0), mload(0x620), f_q))
mstore(0x15e0, addmod(mload(0x13e0), sub(f_q, mload(0x15c0)), f_q))
mstore(0x1600, mulmod(mload(0x15e0), mload(0x1260), f_q))
mstore(0x1620, addmod(mload(0x1180), mload(0x1600), f_q))
mstore(0x1640, mulmod(mload(0x300), mload(0x1620), f_q))
mstore(0x1660, addmod(1, sub(f_q, mload(0x660)), f_q))
mstore(0x1680, mulmod(mload(0x1660), mload(0xfa0), f_q))
mstore(0x16a0, addmod(mload(0x1640), mload(0x1680), f_q))
mstore(0x16c0, mulmod(mload(0x300), mload(0x16a0), f_q))
mstore(0x16e0, mulmod(mload(0x660), mload(0x660), f_q))
mstore(0x1700, addmod(mload(0x16e0), sub(f_q, mload(0x660)), f_q))
mstore(0x1720, mulmod(mload(0x1700), mload(0xec0), f_q))
mstore(0x1740, addmod(mload(0x16c0), mload(0x1720), f_q))
mstore(0x1760, mulmod(mload(0x300), mload(0x1740), f_q))
mstore(0x1780, addmod(mload(0x6a0), mload(0x180), f_q))
mstore(0x17a0, mulmod(mload(0x1780), mload(0x680), f_q))
mstore(0x17c0, addmod(mload(0x6e0), mload(0x1e0), f_q))
mstore(0x17e0, mulmod(mload(0x17c0), mload(0x17a0), f_q))
mstore(0x1800, mulmod(mload(0x4a0), mload(0x560), f_q))
mstore(0x1820, addmod(mload(0x1800), mload(0x180), f_q))
mstore(0x1840, mulmod(mload(0x1820), mload(0x660), f_q))
mstore(0x1860, addmod(mload(0x540), mload(0x1e0), f_q))
mstore(0x1880, mulmod(mload(0x1860), mload(0x1840), f_q))
mstore(0x18a0, addmod(mload(0x17e0), sub(f_q, mload(0x1880)), f_q))
mstore(0x18c0, mulmod(mload(0x18a0), mload(0x1260), f_q))
mstore(0x18e0, addmod(mload(0x1760), mload(0x18c0), f_q))
mstore(0x1900, mulmod(mload(0x300), mload(0x18e0), f_q))
mstore(0x1920, addmod(mload(0x6a0), sub(f_q, mload(0x6e0)), f_q))
mstore(0x1940, mulmod(mload(0x1920), mload(0xfa0), f_q))
mstore(0x1960, addmod(mload(0x1900), mload(0x1940), f_q))
mstore(0x1980, mulmod(mload(0x300), mload(0x1960), f_q))
mstore(0x19a0, mulmod(mload(0x1920), mload(0x1260), f_q))
mstore(0x19c0, addmod(mload(0x6a0), sub(f_q, mload(0x6c0)), f_q))
mstore(0x19e0, mulmod(mload(0x19c0), mload(0x19a0), f_q))
mstore(0x1a00, addmod(mload(0x1980), mload(0x19e0), f_q))
mstore(0x1a20, mulmod(mload(0xa80), mload(0xa80), f_q))
mstore(0x1a40, mulmod(mload(0x1a20), mload(0xa80), f_q))
mstore(0x1a60, mulmod(mload(0x1a40), mload(0xa80), f_q))
mstore(0x1a80, mulmod(1, mload(0xa80), f_q))
mstore(0x1aa0, mulmod(1, mload(0x1a20), f_q))
mstore(0x1ac0, mulmod(1, mload(0x1a40), f_q))
mstore(0x1ae0, mulmod(mload(0x1a00), mload(0xaa0), f_q))
mstore(0x1b00, mulmod(mload(0x8a0), mload(0x460), f_q))
mstore(0x1b20, mulmod(mload(0x1b00), mload(0x460), f_q))
mstore(0x1b40, mulmod(mload(0x460), 1, f_q))
mstore(0x1b60, addmod(mload(0x820), sub(f_q, mload(0x1b40)), f_q))
mstore(0x1b80, mulmod(mload(0x460), 4443263508319656594054352481848447997537391617204595126809744742387004492585, f_q))
mstore(0x1ba0, addmod(mload(0x820), sub(f_q, mload(0x1b80)), f_q))
mstore(0x1bc0, mulmod(mload(0x460), 5857228514216831962358810454360739186987616060007133076514874820078026801648, f_q))
mstore(0x1be0, addmod(mload(0x820), sub(f_q, mload(0x1bc0)), f_q))
mstore(0x1c00, mulmod(mload(0x460), 14978482549995272940995530918097137114536569299992887607386680153997031922392, f_q))
mstore(0x1c20, addmod(mload(0x820), sub(f_q, mload(0x1c00)), f_q))
mstore(0x1c40, mulmod(mload(0x460), 19671853614403325433334785013442879012032153960035114761748042217991436932142, f_q))
mstore(0x1c60, addmod(mload(0x820), sub(f_q, mload(0x1c40)), f_q))
{
            let result := mulmod(mload(0x820), mulmod(mload(0x1b00), 6429953344696991278576351080874112723817581992562333709956802483867864219907, f_q), f_q)
result := addmod(mulmod(mload(0x460), mulmod(mload(0x1b00), 15458289527142283943670054664383162364730782407853700633741401702707944275710, f_q), f_q), result, f_q)
mstore(7296, result)
        }
{
            let result := mulmod(mload(0x820), mulmod(mload(0x1b00), 7994814150416715914263940213242976384465612661982219046850769428271885446695, f_q), f_q)
result := addmod(mulmod(mload(0x460), mulmod(mload(0x1b00), 20734992668899217319464998071864428847715309308997442417757509835792983423210, f_q), f_q), result, f_q)
mstore(7328, result)
        }
{
            let result := mulmod(mload(0x820), mulmod(mload(0x1b00), 20734992668899217319464998071864428847715309308997442417757509835792983423210, f_q), f_q)
result := addmod(mulmod(mload(0x460), mulmod(mload(0x1b00), 15196417582322000994554515848649792706633032999765111570166987313817578467225, f_q), f_q), result, f_q)
mstore(7360, result)
        }
{
            let result := mulmod(mload(0x820), mulmod(mload(0x1b00), 13186392197291051195992994838235220685728012647809583173547162836092719485706, f_q), f_q)
result := addmod(mulmod(mload(0x460), mulmod(mload(0x1b00), 9013357159224640383171299945667942300444546564758124151138895740174180697694, f_q), f_q), result, f_q)
mstore(7392, result)
        }
mstore(0x1d00, mulmod(1, mload(0x1b60), f_q))
mstore(0x1d20, mulmod(mload(0x1d00), mload(0x1ba0), f_q))
mstore(0x1d40, mulmod(mload(0x1d20), mload(0x1c60), f_q))
mstore(0x1d60, mulmod(mload(0x1d40), mload(0x1c20), f_q))
{
            let result := mulmod(mload(0x820), mulmod(mload(0x460), 17444979363519618628192053263408827091010972783211439216888459444188804003033, f_q), f_q)
result := addmod(mulmod(mload(0x460), mulmod(mload(0x460), 4443263508319656594054352481848447997537391617204595126809744742387004492584, f_q), f_q), result, f_q)
mstore(7552, result)
        }
{
            let result := mulmod(mload(0x820), mulmod(mload(0x460), 4443263508319656594054352481848447997537391617204595126809744742387004492584, f_q), f_q)
result := addmod(mulmod(mload(0x460), mulmod(mload(0x460), 6659652765755606382965973213662844074053602057585514708759906710971376056060, f_q), f_q), result, f_q)
mstore(7584, result)
        }
{
            let result := mulmod(mload(0x820), mulmod(mload(0x460), 16031014357622443259887595290896535901560748340408901267183329366497781693970, f_q), f_q)
result := addmod(mulmod(mload(0x460), mulmod(mload(0x460), 5857228514216831962358810454360739186987616060007133076514874820078026801647, f_q), f_q), result, f_q)
mstore(7616, result)
        }
{
            let result := mulmod(mload(0x820), mulmod(mload(0x460), 5857228514216831962358810454360739186987616060007133076514874820078026801647, f_q), f_q)
result := addmod(mulmod(mload(0x460), mulmod(mload(0x460), 13540488431440286398874400643451636701363704118465147976969707232987025353677, f_q), f_q), result, f_q)
mstore(7648, result)
        }
mstore(0x1e00, mulmod(mload(0x1d00), mload(0x1be0), f_q))
{
            let result := mulmod(mload(0x820), 1, f_q)
result := addmod(mulmod(mload(0x460), 21888242871839275222246405745257275088548364400416034343698204186575808495616, f_q), result, f_q)
mstore(7712, result)
        }
{
            let prod := mload(0x1c80)

                prod := mulmod(mload(0x1ca0), prod, f_q)
                mstore(0x1e40, prod)
            
                prod := mulmod(mload(0x1cc0), prod, f_q)
                mstore(0x1e60, prod)
            
                prod := mulmod(mload(0x1ce0), prod, f_q)
                mstore(0x1e80, prod)
            
                prod := mulmod(mload(0x1d80), prod, f_q)
                mstore(0x1ea0, prod)
            
                prod := mulmod(mload(0x1da0), prod, f_q)
                mstore(0x1ec0, prod)
            
                prod := mulmod(mload(0x1d20), prod, f_q)
                mstore(0x1ee0, prod)
            
                prod := mulmod(mload(0x1dc0), prod, f_q)
                mstore(0x1f00, prod)
            
                prod := mulmod(mload(0x1de0), prod, f_q)
                mstore(0x1f20, prod)
            
                prod := mulmod(mload(0x1e00), prod, f_q)
                mstore(0x1f40, prod)
            
                prod := mulmod(mload(0x1e20), prod, f_q)
                mstore(0x1f60, prod)
            
                prod := mulmod(mload(0x1d00), prod, f_q)
                mstore(0x1f80, prod)
            
        }
mstore(0x1fc0, 32)
mstore(0x1fe0, 32)
mstore(0x2000, 32)
mstore(0x2020, mload(0x1f80))
mstore(0x2040, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
mstore(0x2060, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
success := and(eq(staticcall(gas(), 0x5, 0x1fc0, 0xc0, 0x1fa0, 0x20), 1), success)
{
            
            let inv := mload(0x1fa0)
            let v
        
                    v := mload(0x1d00)
                    mstore(7424, mulmod(mload(0x1f60), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1e20)
                    mstore(7712, mulmod(mload(0x1f40), inv, f_q))
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
                
                    v := mload(0x1d20)
                    mstore(7456, mulmod(mload(0x1ec0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1da0)
                    mstore(7584, mulmod(mload(0x1ea0), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1d80)
                    mstore(7552, mulmod(mload(0x1e80), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1ce0)
                    mstore(7392, mulmod(mload(0x1e60), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1cc0)
                    mstore(7360, mulmod(mload(0x1e40), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x1ca0)
                    mstore(7328, mulmod(mload(0x1c80), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                mstore(0x1c80, inv)

        }
{
            let result := mload(0x1c80)
result := addmod(mload(0x1ca0), result, f_q)
result := addmod(mload(0x1cc0), result, f_q)
result := addmod(mload(0x1ce0), result, f_q)
mstore(8320, result)
        }
mstore(0x20a0, mulmod(mload(0x1d60), mload(0x1d20), f_q))
{
            let result := mload(0x1d80)
result := addmod(mload(0x1da0), result, f_q)
mstore(8384, result)
        }
mstore(0x20e0, mulmod(mload(0x1d60), mload(0x1e00), f_q))
{
            let result := mload(0x1dc0)
result := addmod(mload(0x1de0), result, f_q)
mstore(8448, result)
        }
mstore(0x2120, mulmod(mload(0x1d60), mload(0x1d00), f_q))
{
            let result := mload(0x1e20)
mstore(8512, result)
        }
{
            let prod := mload(0x2080)

                prod := mulmod(mload(0x20c0), prod, f_q)
                mstore(0x2160, prod)
            
                prod := mulmod(mload(0x2100), prod, f_q)
                mstore(0x2180, prod)
            
                prod := mulmod(mload(0x2140), prod, f_q)
                mstore(0x21a0, prod)
            
        }
mstore(0x21e0, 32)
mstore(0x2200, 32)
mstore(0x2220, 32)
mstore(0x2240, mload(0x21a0))
mstore(0x2260, 21888242871839275222246405745257275088548364400416034343698204186575808495615)
mstore(0x2280, 21888242871839275222246405745257275088548364400416034343698204186575808495617)
success := and(eq(staticcall(gas(), 0x5, 0x21e0, 0xc0, 0x21c0, 0x20), 1), success)
{
            
            let inv := mload(0x21c0)
            let v
        
                    v := mload(0x2140)
                    mstore(8512, mulmod(mload(0x2180), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x2100)
                    mstore(8448, mulmod(mload(0x2160), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                
                    v := mload(0x20c0)
                    mstore(8384, mulmod(mload(0x2080), inv, f_q))
                    inv := mulmod(v, inv, f_q)
                mstore(0x2080, inv)

        }
mstore(0x22a0, mulmod(mload(0x20a0), mload(0x20c0), f_q))
mstore(0x22c0, mulmod(mload(0x20e0), mload(0x2100), f_q))
mstore(0x22e0, mulmod(mload(0x2120), mload(0x2140), f_q))
mstore(0x2300, mulmod(mload(0x720), mload(0x720), f_q))
mstore(0x2320, mulmod(mload(0x2300), mload(0x720), f_q))
mstore(0x2340, mulmod(mload(0x2320), mload(0x720), f_q))
mstore(0x2360, mulmod(mload(0x2340), mload(0x720), f_q))
mstore(0x2380, mulmod(mload(0x2360), mload(0x720), f_q))
mstore(0x23a0, mulmod(mload(0x2380), mload(0x720), f_q))
mstore(0x23c0, mulmod(mload(0x23a0), mload(0x720), f_q))
mstore(0x23e0, mulmod(mload(0x23c0), mload(0x720), f_q))
mstore(0x2400, mulmod(mload(0x23e0), mload(0x720), f_q))
mstore(0x2420, mulmod(mload(0x780), mload(0x780), f_q))
mstore(0x2440, mulmod(mload(0x2420), mload(0x780), f_q))
mstore(0x2460, mulmod(mload(0x2440), mload(0x780), f_q))
{
            let result := mulmod(mload(0x4a0), mload(0x1c80), f_q)
result := addmod(mulmod(mload(0x4c0), mload(0x1ca0), f_q), result, f_q)
result := addmod(mulmod(mload(0x4e0), mload(0x1cc0), f_q), result, f_q)
result := addmod(mulmod(mload(0x500), mload(0x1ce0), f_q), result, f_q)
mstore(9344, result)
        }
mstore(0x24a0, mulmod(mload(0x2480), mload(0x2080), f_q))
mstore(0x24c0, mulmod(sub(f_q, mload(0x24a0)), 1, f_q))
mstore(0x24e0, mulmod(mload(0x24c0), 1, f_q))
mstore(0x2500, mulmod(1, mload(0x20a0), f_q))
{
            let result := mulmod(mload(0x620), mload(0x1d80), f_q)
result := addmod(mulmod(mload(0x640), mload(0x1da0), f_q), result, f_q)
mstore(9504, result)
        }
mstore(0x2540, mulmod(mload(0x2520), mload(0x22a0), f_q))
mstore(0x2560, mulmod(sub(f_q, mload(0x2540)), 1, f_q))
mstore(0x2580, mulmod(mload(0x2500), 1, f_q))
{
            let result := mulmod(mload(0x660), mload(0x1d80), f_q)
result := addmod(mulmod(mload(0x680), mload(0x1da0), f_q), result, f_q)
mstore(9632, result)
        }
mstore(0x25c0, mulmod(mload(0x25a0), mload(0x22a0), f_q))
mstore(0x25e0, mulmod(sub(f_q, mload(0x25c0)), mload(0x720), f_q))
mstore(0x2600, mulmod(mload(0x2500), mload(0x720), f_q))
mstore(0x2620, addmod(mload(0x2560), mload(0x25e0), f_q))
mstore(0x2640, mulmod(mload(0x2620), mload(0x780), f_q))
mstore(0x2660, mulmod(mload(0x2580), mload(0x780), f_q))
mstore(0x2680, mulmod(mload(0x2600), mload(0x780), f_q))
mstore(0x26a0, addmod(mload(0x24e0), mload(0x2640), f_q))
mstore(0x26c0, mulmod(1, mload(0x20e0), f_q))
{
            let result := mulmod(mload(0x6a0), mload(0x1dc0), f_q)
result := addmod(mulmod(mload(0x6c0), mload(0x1de0), f_q), result, f_q)
mstore(9952, result)
        }
mstore(0x2700, mulmod(mload(0x26e0), mload(0x22c0), f_q))
mstore(0x2720, mulmod(sub(f_q, mload(0x2700)), 1, f_q))
mstore(0x2740, mulmod(mload(0x26c0), 1, f_q))
mstore(0x2760, mulmod(mload(0x2720), mload(0x2420), f_q))
mstore(0x2780, mulmod(mload(0x2740), mload(0x2420), f_q))
mstore(0x27a0, addmod(mload(0x26a0), mload(0x2760), f_q))
mstore(0x27c0, mulmod(1, mload(0x2120), f_q))
{
            let result := mulmod(mload(0x6e0), mload(0x1e20), f_q)
mstore(10208, result)
        }
mstore(0x2800, mulmod(mload(0x27e0), mload(0x22e0), f_q))
mstore(0x2820, mulmod(sub(f_q, mload(0x2800)), 1, f_q))
mstore(0x2840, mulmod(mload(0x27c0), 1, f_q))
{
            let result := mulmod(mload(0x520), mload(0x1e20), f_q)
mstore(10336, result)
        }
mstore(0x2880, mulmod(mload(0x2860), mload(0x22e0), f_q))
mstore(0x28a0, mulmod(sub(f_q, mload(0x2880)), mload(0x720), f_q))
mstore(0x28c0, mulmod(mload(0x27c0), mload(0x720), f_q))
mstore(0x28e0, addmod(mload(0x2820), mload(0x28a0), f_q))
{
            let result := mulmod(mload(0x540), mload(0x1e20), f_q)
mstore(10496, result)
        }
mstore(0x2920, mulmod(mload(0x2900), mload(0x22e0), f_q))
mstore(0x2940, mulmod(sub(f_q, mload(0x2920)), mload(0x2300), f_q))
mstore(0x2960, mulmod(mload(0x27c0), mload(0x2300), f_q))
mstore(0x2980, addmod(mload(0x28e0), mload(0x2940), f_q))
{
            let result := mulmod(mload(0x560), mload(0x1e20), f_q)
mstore(10656, result)
        }
mstore(0x29c0, mulmod(mload(0x29a0), mload(0x22e0), f_q))
mstore(0x29e0, mulmod(sub(f_q, mload(0x29c0)), mload(0x2320), f_q))
mstore(0x2a00, mulmod(mload(0x27c0), mload(0x2320), f_q))
mstore(0x2a20, addmod(mload(0x2980), mload(0x29e0), f_q))
{
            let result := mulmod(mload(0x580), mload(0x1e20), f_q)
mstore(10816, result)
        }
mstore(0x2a60, mulmod(mload(0x2a40), mload(0x22e0), f_q))
mstore(0x2a80, mulmod(sub(f_q, mload(0x2a60)), mload(0x2340), f_q))
mstore(0x2aa0, mulmod(mload(0x27c0), mload(0x2340), f_q))
mstore(0x2ac0, addmod(mload(0x2a20), mload(0x2a80), f_q))
{
            let result := mulmod(mload(0x5c0), mload(0x1e20), f_q)
mstore(10976, result)
        }
mstore(0x2b00, mulmod(mload(0x2ae0), mload(0x22e0), f_q))
mstore(0x2b20, mulmod(sub(f_q, mload(0x2b00)), mload(0x2360), f_q))
mstore(0x2b40, mulmod(mload(0x27c0), mload(0x2360), f_q))
mstore(0x2b60, addmod(mload(0x2ac0), mload(0x2b20), f_q))
{
            let result := mulmod(mload(0x5e0), mload(0x1e20), f_q)
mstore(11136, result)
        }
mstore(0x2ba0, mulmod(mload(0x2b80), mload(0x22e0), f_q))
mstore(0x2bc0, mulmod(sub(f_q, mload(0x2ba0)), mload(0x2380), f_q))
mstore(0x2be0, mulmod(mload(0x27c0), mload(0x2380), f_q))
mstore(0x2c00, addmod(mload(0x2b60), mload(0x2bc0), f_q))
{
            let result := mulmod(mload(0x600), mload(0x1e20), f_q)
mstore(11296, result)
        }
mstore(0x2c40, mulmod(mload(0x2c20), mload(0x22e0), f_q))
mstore(0x2c60, mulmod(sub(f_q, mload(0x2c40)), mload(0x23a0), f_q))
mstore(0x2c80, mulmod(mload(0x27c0), mload(0x23a0), f_q))
mstore(0x2ca0, addmod(mload(0x2c00), mload(0x2c60), f_q))
mstore(0x2cc0, mulmod(mload(0x1a80), mload(0x2120), f_q))
mstore(0x2ce0, mulmod(mload(0x1aa0), mload(0x2120), f_q))
mstore(0x2d00, mulmod(mload(0x1ac0), mload(0x2120), f_q))
{
            let result := mulmod(mload(0x1ae0), mload(0x1e20), f_q)
mstore(11552, result)
        }
mstore(0x2d40, mulmod(mload(0x2d20), mload(0x22e0), f_q))
mstore(0x2d60, mulmod(sub(f_q, mload(0x2d40)), mload(0x23c0), f_q))
mstore(0x2d80, mulmod(mload(0x27c0), mload(0x23c0), f_q))
mstore(0x2da0, mulmod(mload(0x2cc0), mload(0x23c0), f_q))
mstore(0x2dc0, mulmod(mload(0x2ce0), mload(0x23c0), f_q))
mstore(0x2de0, mulmod(mload(0x2d00), mload(0x23c0), f_q))
mstore(0x2e00, addmod(mload(0x2ca0), mload(0x2d60), f_q))
{
            let result := mulmod(mload(0x5a0), mload(0x1e20), f_q)
mstore(11808, result)
        }
mstore(0x2e40, mulmod(mload(0x2e20), mload(0x22e0), f_q))
mstore(0x2e60, mulmod(sub(f_q, mload(0x2e40)), mload(0x23e0), f_q))
mstore(0x2e80, mulmod(mload(0x27c0), mload(0x23e0), f_q))
mstore(0x2ea0, addmod(mload(0x2e00), mload(0x2e60), f_q))
mstore(0x2ec0, mulmod(mload(0x2ea0), mload(0x2440), f_q))
mstore(0x2ee0, mulmod(mload(0x2840), mload(0x2440), f_q))
mstore(0x2f00, mulmod(mload(0x28c0), mload(0x2440), f_q))
mstore(0x2f20, mulmod(mload(0x2960), mload(0x2440), f_q))
mstore(0x2f40, mulmod(mload(0x2a00), mload(0x2440), f_q))
mstore(0x2f60, mulmod(mload(0x2aa0), mload(0x2440), f_q))
mstore(0x2f80, mulmod(mload(0x2b40), mload(0x2440), f_q))
mstore(0x2fa0, mulmod(mload(0x2be0), mload(0x2440), f_q))
mstore(0x2fc0, mulmod(mload(0x2c80), mload(0x2440), f_q))
mstore(0x2fe0, mulmod(mload(0x2d80), mload(0x2440), f_q))
mstore(0x3000, mulmod(mload(0x2da0), mload(0x2440), f_q))
mstore(0x3020, mulmod(mload(0x2dc0), mload(0x2440), f_q))
mstore(0x3040, mulmod(mload(0x2de0), mload(0x2440), f_q))
mstore(0x3060, mulmod(mload(0x2e80), mload(0x2440), f_q))
mstore(0x3080, addmod(mload(0x27a0), mload(0x2ec0), f_q))
mstore(0x30a0, mulmod(1, mload(0x1d60), f_q))
mstore(0x30c0, mulmod(1, mload(0x820), f_q))
mstore(0x30e0, 0x0000000000000000000000000000000000000000000000000000000000000001)
                    mstore(0x3100, 0x0000000000000000000000000000000000000000000000000000000000000002)
mstore(0x3120, mload(0x3080))
success := and(eq(staticcall(gas(), 0x7, 0x30e0, 0x60, 0x30e0, 0x40), 1), success)
mstore(0x3140, mload(0x30e0))
                    mstore(0x3160, mload(0x3100))
mstore(0x3180, mload(0x40))
                    mstore(0x31a0, mload(0x60))
success := and(eq(staticcall(gas(), 0x6, 0x3140, 0x80, 0x3140, 0x40), 1), success)
mstore(0x31c0, mload(0x220))
                    mstore(0x31e0, mload(0x240))
mstore(0x3200, mload(0x2660))
success := and(eq(staticcall(gas(), 0x7, 0x31c0, 0x60, 0x31c0, 0x40), 1), success)
mstore(0x3220, mload(0x3140))
                    mstore(0x3240, mload(0x3160))
mstore(0x3260, mload(0x31c0))
                    mstore(0x3280, mload(0x31e0))
success := and(eq(staticcall(gas(), 0x6, 0x3220, 0x80, 0x3220, 0x40), 1), success)
mstore(0x32a0, mload(0x260))
                    mstore(0x32c0, mload(0x280))
mstore(0x32e0, mload(0x2680))
success := and(eq(staticcall(gas(), 0x7, 0x32a0, 0x60, 0x32a0, 0x40), 1), success)
mstore(0x3300, mload(0x3220))
                    mstore(0x3320, mload(0x3240))
mstore(0x3340, mload(0x32a0))
                    mstore(0x3360, mload(0x32c0))
success := and(eq(staticcall(gas(), 0x6, 0x3300, 0x80, 0x3300, 0x40), 1), success)
mstore(0x3380, mload(0xe0))
                    mstore(0x33a0, mload(0x100))
mstore(0x33c0, mload(0x2780))
success := and(eq(staticcall(gas(), 0x7, 0x3380, 0x60, 0x3380, 0x40), 1), success)
mstore(0x33e0, mload(0x3300))
                    mstore(0x3400, mload(0x3320))
mstore(0x3420, mload(0x3380))
                    mstore(0x3440, mload(0x33a0))
success := and(eq(staticcall(gas(), 0x6, 0x33e0, 0x80, 0x33e0, 0x40), 1), success)
mstore(0x3460, mload(0x120))
                    mstore(0x3480, mload(0x140))
mstore(0x34a0, mload(0x2ee0))
success := and(eq(staticcall(gas(), 0x7, 0x3460, 0x60, 0x3460, 0x40), 1), success)
mstore(0x34c0, mload(0x33e0))
                    mstore(0x34e0, mload(0x3400))
mstore(0x3500, mload(0x3460))
                    mstore(0x3520, mload(0x3480))
success := and(eq(staticcall(gas(), 0x6, 0x34c0, 0x80, 0x34c0, 0x40), 1), success)
mstore(0x3540, 0x183af939bc3d5142ce8ed5ce95bd85a420c0353b3c5d6fa884f90b7735d3f69f)
                    mstore(0x3560, 0x24ebb2d185b12c52a0ec1c645fc17f69ccaf329c7a1fd448ebce1aaa1664d48c)
mstore(0x3580, mload(0x2f00))
success := and(eq(staticcall(gas(), 0x7, 0x3540, 0x60, 0x3540, 0x40), 1), success)
mstore(0x35a0, mload(0x34c0))
                    mstore(0x35c0, mload(0x34e0))
mstore(0x35e0, mload(0x3540))
                    mstore(0x3600, mload(0x3560))
success := and(eq(staticcall(gas(), 0x6, 0x35a0, 0x80, 0x35a0, 0x40), 1), success)
mstore(0x3620, 0x11c77de58da2520b241eccf4c2f9647657c73682f51a9dcbce3f4cdb8ce697f2)
                    mstore(0x3640, 0x2d8c06867e56d50cd072ff45fb47de1f41fc672dbe9b0306f28b7618e538b36f)
mstore(0x3660, mload(0x2f20))
success := and(eq(staticcall(gas(), 0x7, 0x3620, 0x60, 0x3620, 0x40), 1), success)
mstore(0x3680, mload(0x35a0))
                    mstore(0x36a0, mload(0x35c0))
mstore(0x36c0, mload(0x3620))
                    mstore(0x36e0, mload(0x3640))
success := and(eq(staticcall(gas(), 0x6, 0x3680, 0x80, 0x3680, 0x40), 1), success)
mstore(0x3700, 0x0bb6862c0aa303c631681a3b95ad0ae980cb01c2071968b4aca7d8e527adb291)
                    mstore(0x3720, 0x16459bc1d43f05c69f96bef5ff4ecc38a08388e3032e84327754ed3d1a041412)
mstore(0x3740, mload(0x2f40))
success := and(eq(staticcall(gas(), 0x7, 0x3700, 0x60, 0x3700, 0x40), 1), success)
mstore(0x3760, mload(0x3680))
                    mstore(0x3780, mload(0x36a0))
mstore(0x37a0, mload(0x3700))
                    mstore(0x37c0, mload(0x3720))
success := and(eq(staticcall(gas(), 0x6, 0x3760, 0x80, 0x3760, 0x40), 1), success)
mstore(0x37e0, 0x2434901728447a4ff90a119a3a6851676011db82fb92bf56b43ee0e9360a86b7)
                    mstore(0x3800, 0x24bb9b79659969c635e0853ac3a295e47403affe59e8436577b148fe96c54e96)
mstore(0x3820, mload(0x2f60))
success := and(eq(staticcall(gas(), 0x7, 0x37e0, 0x60, 0x37e0, 0x40), 1), success)
mstore(0x3840, mload(0x3760))
                    mstore(0x3860, mload(0x3780))
mstore(0x3880, mload(0x37e0))
                    mstore(0x38a0, mload(0x3800))
success := and(eq(staticcall(gas(), 0x6, 0x3840, 0x80, 0x3840, 0x40), 1), success)
mstore(0x38c0, 0x158a42eb7eb7e3e6e598b77eaa650570b10eff979407fe80ac75dcb9c4257e45)
                    mstore(0x38e0, 0x1470da407a53a39a598d1fbe7b5a235dec9a39ed12ae69f230ac555393526970)
mstore(0x3900, mload(0x2f80))
success := and(eq(staticcall(gas(), 0x7, 0x38c0, 0x60, 0x38c0, 0x40), 1), success)
mstore(0x3920, mload(0x3840))
                    mstore(0x3940, mload(0x3860))
mstore(0x3960, mload(0x38c0))
                    mstore(0x3980, mload(0x38e0))
success := and(eq(staticcall(gas(), 0x6, 0x3920, 0x80, 0x3920, 0x40), 1), success)
mstore(0x39a0, 0x254f23875a698cf01d33e9f17abc72182de245ce80a77f3dc3479469635b673e)
                    mstore(0x39c0, 0x1c9a7d1ffb724143710726ddad15a986b596f36064457aaa0516c82576a62fa9)
mstore(0x39e0, mload(0x2fa0))
success := and(eq(staticcall(gas(), 0x7, 0x39a0, 0x60, 0x39a0, 0x40), 1), success)
mstore(0x3a00, mload(0x3920))
                    mstore(0x3a20, mload(0x3940))
mstore(0x3a40, mload(0x39a0))
                    mstore(0x3a60, mload(0x39c0))
success := and(eq(staticcall(gas(), 0x6, 0x3a00, 0x80, 0x3a00, 0x40), 1), success)
mstore(0x3a80, 0x25092cd9a21407c8610ead3f700b37dccc11e683311ef4b5d0c45fefd0a52bde)
                    mstore(0x3aa0, 0x2380bc66478d6b8861be98d6afe960a613eadf2a7cc063578f1d84f15ee595d2)
mstore(0x3ac0, mload(0x2fc0))
success := and(eq(staticcall(gas(), 0x7, 0x3a80, 0x60, 0x3a80, 0x40), 1), success)
mstore(0x3ae0, mload(0x3a00))
                    mstore(0x3b00, mload(0x3a20))
mstore(0x3b20, mload(0x3a80))
                    mstore(0x3b40, mload(0x3aa0))
success := and(eq(staticcall(gas(), 0x6, 0x3ae0, 0x80, 0x3ae0, 0x40), 1), success)
mstore(0x3b60, mload(0x340))
                    mstore(0x3b80, mload(0x360))
mstore(0x3ba0, mload(0x2fe0))
success := and(eq(staticcall(gas(), 0x7, 0x3b60, 0x60, 0x3b60, 0x40), 1), success)
mstore(0x3bc0, mload(0x3ae0))
                    mstore(0x3be0, mload(0x3b00))
mstore(0x3c00, mload(0x3b60))
                    mstore(0x3c20, mload(0x3b80))
success := and(eq(staticcall(gas(), 0x6, 0x3bc0, 0x80, 0x3bc0, 0x40), 1), success)
mstore(0x3c40, mload(0x380))
                    mstore(0x3c60, mload(0x3a0))
mstore(0x3c80, mload(0x3000))
success := and(eq(staticcall(gas(), 0x7, 0x3c40, 0x60, 0x3c40, 0x40), 1), success)
mstore(0x3ca0, mload(0x3bc0))
                    mstore(0x3cc0, mload(0x3be0))
mstore(0x3ce0, mload(0x3c40))
                    mstore(0x3d00, mload(0x3c60))
success := and(eq(staticcall(gas(), 0x6, 0x3ca0, 0x80, 0x3ca0, 0x40), 1), success)
mstore(0x3d20, mload(0x3c0))
                    mstore(0x3d40, mload(0x3e0))
mstore(0x3d60, mload(0x3020))
success := and(eq(staticcall(gas(), 0x7, 0x3d20, 0x60, 0x3d20, 0x40), 1), success)
mstore(0x3d80, mload(0x3ca0))
                    mstore(0x3da0, mload(0x3cc0))
mstore(0x3dc0, mload(0x3d20))
                    mstore(0x3de0, mload(0x3d40))
success := and(eq(staticcall(gas(), 0x6, 0x3d80, 0x80, 0x3d80, 0x40), 1), success)
mstore(0x3e00, mload(0x400))
                    mstore(0x3e20, mload(0x420))
mstore(0x3e40, mload(0x3040))
success := and(eq(staticcall(gas(), 0x7, 0x3e00, 0x60, 0x3e00, 0x40), 1), success)
mstore(0x3e60, mload(0x3d80))
                    mstore(0x3e80, mload(0x3da0))
mstore(0x3ea0, mload(0x3e00))
                    mstore(0x3ec0, mload(0x3e20))
success := and(eq(staticcall(gas(), 0x6, 0x3e60, 0x80, 0x3e60, 0x40), 1), success)
mstore(0x3ee0, mload(0x2a0))
                    mstore(0x3f00, mload(0x2c0))
mstore(0x3f20, mload(0x3060))
success := and(eq(staticcall(gas(), 0x7, 0x3ee0, 0x60, 0x3ee0, 0x40), 1), success)
mstore(0x3f40, mload(0x3e60))
                    mstore(0x3f60, mload(0x3e80))
mstore(0x3f80, mload(0x3ee0))
                    mstore(0x3fa0, mload(0x3f00))
success := and(eq(staticcall(gas(), 0x6, 0x3f40, 0x80, 0x3f40, 0x40), 1), success)
mstore(0x3fc0, mload(0x7c0))
                    mstore(0x3fe0, mload(0x7e0))
mstore(0x4000, sub(f_q, mload(0x30a0)))
success := and(eq(staticcall(gas(), 0x7, 0x3fc0, 0x60, 0x3fc0, 0x40), 1), success)
mstore(0x4020, mload(0x3f40))
                    mstore(0x4040, mload(0x3f60))
mstore(0x4060, mload(0x3fc0))
                    mstore(0x4080, mload(0x3fe0))
success := and(eq(staticcall(gas(), 0x6, 0x4020, 0x80, 0x4020, 0x40), 1), success)
mstore(0x40a0, mload(0x860))
                    mstore(0x40c0, mload(0x880))
mstore(0x40e0, mload(0x30c0))
success := and(eq(staticcall(gas(), 0x7, 0x40a0, 0x60, 0x40a0, 0x40), 1), success)
mstore(0x4100, mload(0x4020))
                    mstore(0x4120, mload(0x4040))
mstore(0x4140, mload(0x40a0))
                    mstore(0x4160, mload(0x40c0))
success := and(eq(staticcall(gas(), 0x6, 0x4100, 0x80, 0x4100, 0x40), 1), success)
mstore(0x4180, mload(0x4100))
                    mstore(0x41a0, mload(0x4120))
mstore(0x41c0, 0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2)
            mstore(0x41e0, 0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed)
            mstore(0x4200, 0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b)
            mstore(0x4220, 0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa)
mstore(0x4240, mload(0x860))
                    mstore(0x4260, mload(0x880))
mstore(0x4280, 0x0181624e80f3d6ae28df7e01eaeab1c0e919877a3b8a6b7fbc69a6817d596ea2)
            mstore(0x42a0, 0x1783d30dcb12d259bb89098addf6280fa4b653be7a152542a28f7b926e27e648)
            mstore(0x42c0, 0x00ae44489d41a0d179e2dfdc03bddd883b7109f8b6ae316a59e815c1a6b35304)
            mstore(0x42e0, 0x0b2147ab62a386bd63e6de1522109b8c9588ab466f5aadfde8c41ca3749423ee)
success := and(eq(staticcall(gas(), 0x8, 0x4180, 0x180, 0x4180, 0x20), 1), success)
success := and(eq(mload(0x4180), 1), success)

            if not(success) { revert(0, 0) }
            return(0, 0)

                }
            }
        }