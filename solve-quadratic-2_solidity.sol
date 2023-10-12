// SPDX-License-Identifier: MIT
// Nhập 3 giá trị a,b,c vào nút Main và sau đó bấm nút Main và getOutput 
pragma solidity ^0.8.0;

contract QuadraticEquationSolver {
    struct Numerator {
        int b;
        int delta;
        int sum;
        string sign;
    }
    struct Fraction { 
        Numerator numerator;
        int denominator;
    }

    Fraction public root1 = Fraction(Numerator (1,0,0,""),1);
    Fraction public root2 = Fraction(Numerator (1,0,0,""),1);

    string public output = "";

    // int public a = 2;
    // int public b = 3;
    string public debug;

    function calculateQuadraticRoots(int a, int b, int c) public returns (int){
        int delta = b**2 - 4 * a * c;
        if(delta < 0) {
            return 0;
        }
        else if(delta == 0) {
            root1.numerator.b = -b;
            root1.denominator = (2 * a);
            return 1;
        }
        else {
            root1.numerator.b = -b;
            root1.numerator.delta = delta;
            root1.numerator.sign = " + ";
            root1.denominator = (2 * a);
            

            root2.numerator.b = -b;
            root2.numerator.delta = delta;
            root2.numerator.sign = " - ";
            root2.denominator = (2 * a);

            return 2;
        }   
    }

    function Main(int a, int b, int c) public {
        // reset root
        root1 = Fraction(Numerator (1,0,0,""),1);
        root2 = Fraction(Numerator (1,0,0,""),1);

        int numberRoot = calculateQuadraticRoots(a, b, c);
        if(numberRoot == 0) {
            output = "The equation has no solution";
        } else if (numberRoot == 1) {
            int ValueSquare;
            int remainder;
            ConvertSign(root1);
            (ValueSquare,remainder) = sqrt(root1.numerator.delta);
            if(remainder == 0) {
                (root1.numerator.sum, root1.denominator) = ReduceFraction(root1);
            }
            
            output = concatenateStrings("The equation has one solution: ", FractionToString(root1));
        } else {
            int remainder;
            int ValueSquare;
            ConvertSign(root1);
            (ValueSquare,remainder) = sqrt(root1.numerator.delta);
            if(remainder == 0) {
                (root1.numerator.sum, root1.denominator) = ReduceFraction(root1);
            }

            ConvertSign(root2);
            (ValueSquare,remainder) = sqrt(root2.numerator.delta);
            if(remainder == 0) {
                (root2.numerator.sum, root2.denominator) = ReduceFraction(root2);
            }

            output = concatenateStrings(concatenateStrings("The equation has two solution: ", FractionToString(root1)), concatenateStrings(" and ", FractionToString(root2)));
        }
    }

    // Cộng lại tử số nếu căn được
    function sumIfSoloveSquare(Fraction memory root) public pure returns (Fraction memory){
        int ValueSquare;
        int remainder;
        (ValueSquare,remainder)= sqrt(root.numerator.delta);
        
        if(keccak256(abi.encodePacked(root.numerator.sign)) == keccak256(abi.encodePacked(" + "))) {
            root.numerator.sum = root.numerator.b + ValueSquare;
        } else {
            root.numerator.sum = root.numerator.b - ValueSquare;
        }
        return root;
    }

    // rút gọn phân số
    function ReduceFraction(Fraction memory root) public pure returns (int, int) {
        require(root.denominator != 0, "Denominator cannot be zero.");
        // int ValueSquare;
        // int remainder;
        // (ValueSquare,remainder)= sqrt(root.numerator.delta);
        // if(keccak256(abi.encodePacked(root.numerator.sign)) == keccak256(abi.encodePacked(" + ")) {
        //     root.numerator.sum = root.numerator.b + ValueSquare;
        // } else {
        //     root.numerator.sum = root.numerator.b - ValueSquare;
        // }

        root = sumIfSoloveSquare(root);
        
        int gcd = findGCD(absoluteValue(root.numerator.sum), absoluteValue(root.denominator));
        
        int reducedNumerator = root.numerator.sum / gcd;
        int reducedDenominator = root.denominator / gcd;
        
        return (reducedNumerator, reducedDenominator);
    }

    function findGCD(int a, int b) internal pure returns (int) {
        if (b == 0) {
            return a;
        }
        return findGCD(b, a % b);
    }

    function FractionToString(Fraction memory root) public pure returns (string memory) {
        string memory message = "";
        string memory numeratorString = "";
        if(root.numerator.sum != 0) {
            numeratorString = intToString(root.numerator.sum);
        } else {
            // debug = 
            numeratorString = concatenateStrings(intToString(root.numerator.b), concatenateStrings(root.numerator.sign, concatenateStrings("sqrt(", concatenateStrings(intToString(root.numerator.delta), ")"))));
        }

        if(root.denominator != 1){
            message = concatenateStrings(concatenateStrings(numeratorString, "/"), intToString(root.denominator));
        }else {
            message = numeratorString;
        }
        return message;
    }

    function ConvertSign(Fraction memory root) public pure returns (Fraction memory){
        // đổi dấu âm nếu có lên tử
        if(root.denominator < 0) {
            root.denominator = -root.denominator;
            root.numerator.b = -root.numerator.b;
            if(keccak256(abi.encodePacked(root.numerator.sign)) == keccak256(abi.encodePacked(" - "))){
                root.numerator.sign = " + ";
            }
            else {
                root.numerator.sign = " - ";
            }
            
        }
        return root;
    }

    function getOutput() public view  returns (string memory){
        return output;
    }

    // utilities function
    function sqrt(int x) public pure returns (int, int) {
        int z = (x + 1) / 2;
        int y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        int remainder = x - y**2;
        return (y, remainder);

    }
    function concatenateStrings(string memory strA , string memory strB ) public pure returns (string memory) {
        // Chuyển các chuỗi thành mảng ký tự
        bytes memory stringA = bytes(strA);
        bytes memory stringB = bytes(strB);

        // Tạo một mảng ký tự đủ lớn để chứa kết quả
        bytes memory result = new bytes(stringA.length + stringB.length);

        // Nối chuỗi
        for (uint i = 0; i < stringA.length; i++) {
            result[i] = stringA[i];
        }
        for (uint i = 0; i < stringB.length; i++) {
            result[stringA.length + i] = stringB[i];
        }

        // Chuyển mảng ký tự thành chuỗi
        string memory concatenatedString = string(result);
        return concatenatedString;
    }

    function intToString(int256 num) public pure returns (string memory) {
        if (num == 0) {
            return "0";
        }

        bool isNegative = false;
        if (num < 0) {
            isNegative = true;
            num = -num;
        }

        uint256 tempNum = uint256(num);
        uint256 length;

        while (tempNum != 0) {
            length++;
            tempNum /= 10;
        }

        bytes memory str = new bytes(isNegative ? length + 1 : length);
        uint256 index = isNegative ? length + 1 : length;

        while (num != 0) {
            uint256 remainder = uint256(num) % 10;
            num = num / 10;
            str[--index] = bytes1(uint8(48 + remainder));
        }

        if (isNegative) {
            str[0] = "-";
        }

        return string(str);
    }

    function getStruct() public view returns (int, int) {
        return (root1.numerator.sum, root1.denominator);
    }

    function absoluteValue(int number) public pure returns (int) {
        if (number < 0) {
            return int(-number);
        } else {
            return int(number);
        }
    }
}