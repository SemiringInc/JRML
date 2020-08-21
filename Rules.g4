/* JSON-NLP to Graph / RDF Mapper Rules grammar

   (C) 2020 by Semiring Inc, Damir Cavar, Anthony Meyer

   The grammar definition for the mapping language from JSON-NLP
   to RDF (and graphs) defines:
   - Macros
   - Rules
   Macros combine matching expressions.
   Rules describe Matching expressions and the output generated in
   form of RDF triples, JSON-LD, or graph specifications.
 */

grammar Rules;

COLON        : ':' ;
SEMICOLON    : ';' ;
DOT          : '.' ;
ARROW        : ('-'|'=')+ '>' ;
EQUALS       : '=' ;
NOTEQUALS    : '!=' ;
LARGER       : '>' ;
SMALLER      : '<' ;
LARGEREQUAL  : '>=' ;
SMALLEREQUAL : '<=' ;
COMMA        : ',' ;
OPENBRACKET  : '[' ;
CLOSEBRACKET : ']' ;
OPENSET      : '(' ;
CLOSESET     : ')' ;
INT          : [0-9]+ ;
DOUBLE       : [0-9]+'.'[0-9]+ ;
BOOLTRUE     : 'true' | 'True' | 'TRUE' ;
BOOLFALSE    : 'false' | 'False' | 'FALSE' ;
RULEKEYWORD  : 'Rule'|'rule'|'RULE' ;
MACROKEYWORD : 'Macro' | 'macro' | 'MACRO' ;
STRINGB      : '"' ;
ID           : [a-zA-Z][a-zA-Z0-9_]* ; // match identifiers
WS           : [ \t\r\n]+ -> skip ;    // skip spaces, tabs, newlines
LINE_COMMENT : '//' ~[\r\n]* -> skip ;
COMMENT      : '/*' .*? '*/' -> skip ;

// --------------------------------------------------------------------

// test: see test.dat
input : (ruleExp|aliasExp)+  // main input def, set of rules
    ;

ruleExp : RULEKEYWORD rulenameExp matchExpressions ARROW tripleExpressions SEMICOLON ;
rulenameExp : ruleName (OPENBRACKET ruleFeatureExp CLOSEBRACKET)? COLON // ruleName followed by :
    ;
ruleFeatureExp : ruleFeatureProp (COMMA ruleFeatureProp)* ;
ruleFeatureProp : rulePropertyExp (EQUALS ruleValueExp)? ;
rulePropertyExp : ID ;
ruleValueExp : STRINGB valueString STRINGB
    | valueInt
    | valueDouble
    | valueBool
    ;
ruleName : ID ;

aliasExp : MACROKEYWORD aliasName COLON aliasProps SEMICOLON ;
aliasName : ID ;
aliasProps : (methodName|OPENBRACKET featureExp CLOSEBRACKET)+ ;

matchExpressions : matchExp+ ;
matchExp : matchVariable (DOT methodName)* (OPENBRACKET featureExp CLOSEBRACKET)? ;
matchVariable : ID ;

methodName : getSubject
    | getSubjectPhrase
    | getSubjectCompound
    | getObject
    | getObjectPhrase
    | getObjectCompound
    ;

getSubject         : 'subject' ;
getSubjectPhrase   : 'subjectPhrase' ;
getSubjectCompound : 'subjectCompound' ;
getObject          : 'object' ;
getObjectPhrase    : 'objectPhrase' ;
getObjectCompound  : 'objectCompound' ;

// feature expression is attribute = value or for logical checks just attribute
featureExp : featureProp (COMMA featureProp)* ;

featureProp : propertyExp (EQUALS valueExp)? ;

// properties are ID type of strings
propertyExp : ID ;

// values can be strings with double quotes, integers, doubles, fals or true
valueExp : STRINGB valueString STRINGB
    | valueInt
    | valueDouble
    | valueBool
    ;

valueString : ID ;

valueInt    : INT ;

valueDouble : DOUBLE ;

valueBool   : BOOLFALSE | BOOLTRUE ;

tripleExpressions : OPENSET tripleExp (COMMA tripleExp)* CLOSESET
    | tripleExp
    ;

// a triple is:
// (X, Y, Z)
// where X, Y, and Z can be a variable (mathing concept), a string/URL ID
// a predicate or rconcept can be a value (string, int, double, boolean)
tripleExp : OPENSET lconcept COMMA predicateExp COMMA rconcept CLOSESET ;

lconcept      : concept (DOT outputFunctions)?  (OPENBRACKET lcFeatureExp CLOSEBRACKET)? ;

lcFeatureExp  : lcFeatureProp (COMMA lcFeatureProp)* ;

// if not value, then set value to true
lcFeatureProp : lcPropertyExp (EQUALS valueExp)? ;

lcPropertyExp : ID ;

rconcept  : ( concept (DOT outputFunctions)? |
              INT |
              DOUBLE |
              STRINGB ID STRINGB |
              BOOLFALSE |
              BOOLTRUE )
            (OPENBRACKET rcFeatureExp CLOSEBRACKET)? ;

rcFeatureExp  : rcFeatureProp (COMMA rcFeatureProp)* ;

// if not value, then set value to true
rcFeatureProp : rcPropertyExp (EQUALS valueExp)? ;

rcPropertyExp : ID ;

predicateExp : predicate ;

predicate : ( ID (DOT outputFunctions)? | STRINGB ID STRINGB ) (OPENBRACKET pFeatureExp CLOSEBRACKET)? ;

pFeatureExp  : pFeatureProp (COMMA pFeatureProp)* ;

// if not value, then set value to true
pFeatureProp : pPropertyExp (EQUALS valueExp)? ;

pPropertyExp : ID ;

concept   : ID ;

outputFunctions : ID ;

