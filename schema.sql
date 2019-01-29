-- source D:\Projects\node\thq\schema.sql

DROP DATABASE IF EXISTS thq;
CREATE DATABASE thq;
USE thq;

-- +-----------------------------------------+
-- |Start Schema for site navigation         |
-- +-----------------------------------------+

CREATE TABLE sys_priv (
	PRIMARY KEY (priv),
	priv VARCHAR(36)
);

-- Store navigation through the site
CREATE TABLE sys_navigation (
    navInnerText VARCHAR(40) NOT NULL, -- Inner text of the <a> element
    navMethod VARCHAR(6) NOT NULL DEFAULT 'GET', -- HTTP Request method
    navPathName VARCHAR(120) NOT NULL, -- Href of the <a> element
    navQueryString VARCHAR(120), -- Optional query string parameter
    navHeader VARCHAR(40), -- Header for link
    navMenu VARCHAR(40), -- Root navigation menu
    navActive BOOLEAN NOT NULL DEFAULT 1,
    navPriv VARCHAR(36), -- Priv associated with link
    navIsNotApi BOOLEAN NOT NULL, -- Whether or not the route is an api

    PRIMARY KEY (navMethod, navPathName),

    FOREIGN KEY (navPriv)
	REFERENCES sys_priv (priv)
	ON DELETE RESTRICT
	ON UPDATE CASCADE
);

CREATE TABLE sys_role (
    rpId CHAR(9) NOT NULL, -- Role ID
    rpPriv VARCHAR(36), -- Priviledge assigned to role
    
    PRIMARY KEY (rpPriv, rpId),

    FOREIGN KEY (rpPriv)
        REFERENCES sys_priv(priv)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- +-----------------------------------------+
-- |Start Schema for nonsig data             |
-- +-----------------------------------------+

-- This data will not be tied to any one user account
CREATE TABLE sys_customer (
    nsNonsig CHAR(9) NOT NULL,
    nsTradeStyle VARCHAR(100) NOT NULL,
    nsAddr1 VARCHAR(40),
    nsAddr2 VARCHAR(40),
    nsCity VARCHAR(40),
    nsState CHAR(2),
    nsPostalCode VARCHAR(10),
    nsCountry CHAR(2) DEFAULT 'US',
    nsBrandKey VARCHAR(4),
    nsIsActive BOOLEAN DEFAULT 1,
    nsIsActiveTHQ BOOLEAN DEFAULT 1,
    nsType CHAR(3),

    PRIMARY KEY (nsNonsig)
);

-- +-----------------------------------------+
-- |Start Document Schema for Users          |
-- +-----------------------------------------+

CREATE TABLE sys_user_nsacl (
    nsaUserId CHAR(36) NOT NULL,
    nsaNonsig CHAR(9) NOT NULL,
    nsaRole CHAR(7) NOT NULL,
    nsaConfirmedByAdmin BOOLEAN NOT NULL DEFAULT 0,
    nsaIsAdmin BOOLEAN NOT NULL DEFAULT FALSE,

    FOREIGN KEY (nsaNonsig)
        REFERENCES sys_customer(nsNonsig)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (nsaRole)
        REFERENCES sys_role(rpId)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Keep this table to a minimum, only to be used for login, password reset
CREATE TABLE sys_user (
    userId CHAR(36) NOT NULL,
    userName VARCHAR(36) NOT NULL UNIQUE,
    userPass BINARY(60),
    userEmail VARCHAR(90) NOT NULL,
    userIsLocked BOOLEAN NOT NULL DEFAULT 0,
    userIsConfirmed BOOLEAN NOT NULL DEFAULT 0, -- Test if user has confirmed their email
    userAwaitingPassword BOOLEAN NOT NULL DEFAULT 0, -- If user has password reset pending
    userConfirmation CHAR(36), -- Token used for confirmation and password reset
    userInvalidLoginAttempts INT(1),
    userDefaultNonsig CHAR(9) NOT NULL,

    PRIMARY KEY (userId),

    INDEX(userName),

    FOREIGN KEY (userDefaultNonsig)
        REFERENCES sys_customer(nsNonsig)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Add final foreign key after creating sys_user
ALTER TABLE sys_user_nsacl ADD 
    FOREIGN KEY (nsaUserId)
        REFERENCES sys_user(userId)
        ON DELETE CASCADE
        ON UPDATE CASCADE;

-- +-----------------------------------------+
-- |Start Document Schema for Docs A,B,C etc |
-- +-----------------------------------------+
/*
    This table seems monolithic, and in some ways it is. But it is absolutely vital to store this
    information in it's own table with it's own columns that are seperate from any dynamic data.
*/
CREATE TABLE doc_final (
    docId CHAR(36) NOT NULL, -- UUIDV4 unique identifier
    docSubmitted DATE, -- When the doc was submitted
    docSourceNumber INT(9) NOT NULL, -- Visible document number
    docB50 INT(3), -- B50 Number for GBMS
    docDealer CHAR(36) NOT NULL, -- Dealer's nonsig
    docShipDate DATE NOT NULL,
    docType INT(2) NOT NULL, -- A,B,E, etc.
    docAcct INT(4), -- Allow null for doc B etc
    docBillToNonsig INT(9), -- Optional bill to nonsig
    docShipToNonsig INT(9),
    docPRAcct INT(2), -- P&R account GM, Chrysler, Ford, etc
    docPRDlrNbr INT(16), -- P&R Dealership Number
    docVehType CHAR(2),
    docModifier INT(1), -- Standard, return, correction
    docAdjustment BOOLEAN, -- Adjustment checkbox
    docIsFleetHQ BOOLEAN, -- FleetHQ check box
    docIsMassMerchant BOOLEAN, -- Doc F Modifier
    dohMassMerchantNumber INT,
    docShipToId CHAR(36), -- Reference an entry in the documentAddresses table
    docShipToName VARCHAR(60) NOT NULL,
    docShipToAddr1 VARCHAR(90),
    docShipToAddr2 VARCHAR(90),
    docShipToCity VARCHAR(90),
    docShipToState CHAR(2),
    docShipToPostalCode VARCHAR(10),
    docBillToId char(26), -- Reference an entry in the documentAddresses table
    docBillToName VARCHAR(60) NOT NULL, 
    docBillToAddr1 VARCHAR(90),
    docBillToAddr2 VARCHAR(90),
    docBillToCity VARCHAR(90),
    docBillToState CHAR(2),
    docBillToPostalCode VARCHAR(10),
    docFleetHQCall INT(10),
    docCorrectionIndicator BOOLEAN,
    docCorrectionReference CHAR(36),
    docCorrectionReason VARCHAR(120),
    docGeoCode INT(9),
    docIsOutOfState BOOLEAN,
    docInvoiceNumber INT(10),
    docInvoiceMicroNumber INT(6),
    docInvoiceDate DATE,
    docInvoiceLastPrinted DATE,
    docInvoiceIsCreditDebit BOOLEAN,
    docInvoiceAmount INT,

    PRIMARY KEY(docId),
    INDEX(docDealer)
);

CREATE TABLE doc_final_req (
    docReq INT AUTO_INCREMENT NOT NULL,
    docId CHAR(36) NOT NULL,
    docReqKeyWord CHAR(3), -- Not a foreign key to allow submitted documents to still reference old requirements
    docReqShortDesc VARCHAR(40),
    docReqValue VARCHAR(40),

    PRIMARY KEY(docReq),
    INDEX(docId),

    FOREIGN KEY (docId)
        REFERENCES doc_final(docId)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Store documents on hold and pending documents in doc_onhold
-- Dynamically pull shipto/billto from doc_prod table
CREATE TABLE doc_onhold (
    dohId CHAR(36) NOT NULL, -- UUIDV4 unique identifier
    dohLastScreen INT(1), -- Last screen the doc was opened to
    dohLastOpened DATE, -- Last time the doc was opened
    dohSourceNumber INT(9) NOT NULL, -- Visible document number
    dohDealer INT(9) NOT NULL, -- Dealer's nonsig
    dohShipDate DATE NOT NULL,
    dohType CHAR(1) NOT NULL, -- A,B,E, etc.
    dohAcct INT(4), -- Allow null for doc B etc
    dohBillToNonsig INT(9), -- Optional bill to nonsig
    dohShipToNonsig INT(9),
    dohPRAcct INT(2), -- P&R account GM, Chrysler, Ford, etc
    dohPRDlrNbr INT(16), -- P&R Dealership Number
    dohVehType CHAR(2), -- LT, AU, TL, ST
    dohModifier INT(1), -- Standard, return, correction
    dohGovModifier CHAR(1), -- Exempt, Federal, State/Local
    dohAdjustment BOOLEAN, -- Adjustment checkbox
    dohFleetHQ BOOLEAN, -- FleetHQ check box
    dohMassMerchant BOOLEAN, -- Doc F Modifier
    dohMassMerchantNumber INT,
    dohShipToId CHAR(36), -- Reference an entry in the documentAddresses table
    dohBillToId CHAR(36), -- Reference an entry in the documentAddresses table
    dohFleetHQCall INT(10),
    dohCorrectionIndicator BOOLEAN,
    dohCorrectionReference CHAR(36),
    dohCorrectionReason VARCHAR(120),
    dohGeoCode INT(9),
    dohIsOutOfState BOOLEAN,

    PRIMARY KEY(dohId),
    INDEX(dohDealer),

    FOREIGN KEY (dohCorrectionReference)
        REFERENCES doc_final(docId)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE doc_prod (
    dpKey INT NOT NULL AUTO_INCREMENT,
    dpDocId CHAR(36) NOT NULL, -- Reference the document that this is connected to
    dpCode INT(9) NOT NULL,
    dpDescription VARCHAR(80),
    dpPartsPrice DECIMAL(7,2),
    dpQuantity INT(4),
    dpIsRetread BOOLEAN,
    dpCustomerOwned BOOLEAN, -- For retread casings only

    PRIMARY KEY(dpKey),

    FOREIGN KEY (dpDocId)
        REFERENCES doc_onhold(dohId)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

-- Store billTo/shipTo addresses for dealers
-- Only allow dealers to access their own addresses
-- Modifying these values will also affect any documents on hold
CREATE TABLE sys_addr (
   -- addrId CHAR(36) NOT NULL, -- Unique UUIDV4 identifying the address
    abNonsig INT NOT NULL AUTO_INCREMENT, -- Simple number to search by
    abOwner INT(9) NOT NULL, -- The creating dealer's nonsig
    abName VARCHAR(60) NOT NULL, -- Searchable name
    abAcct INT(4), -- Tie addr into a certain account, optionally
    abAddr1 VARCHAR(90),
    abAddr2 VARCHAR(90),
    abCity VARCHAR(90),
    abState CHAR(2),
    abPostalCode VARCHAR(10),

    PRIMARY KEY(abNonsig)
);

-- +---------------------------------------------+
-- |Start Document Schema for Gov/National ACCTS |
-- +---------------------------------------------+

-- Store data about the national account
CREATE TABLE sys_customer_account (
    naId CHAR(36) NOT NULL,
    naNbr VARCHAR(7),
    naNonsig VARCHAR(7),
    naName VARCHAR(40),
    naAddr1 VARCHAR(40),
    naAddr2 VARCHAR(40),
    naPostalCode VARCHAR(10),
    naCity VARCHAR(40),
    naState CHAR(2),
    naCountry CHAR(2),
    naIsOnCreditHold BOOLEAN,
    naIsActive BOOLEAN,

    PRIMARY KEY (naId),

    INDEX(naNbr, naNonsig)
);

CREATE TABLE sys_addr_ship (
    stnId CHAR(36) NOT NULL,
    stnAcct CHAR(36),
    stnNonsig VARCHAR(7),
    stnName VARCHAR(40),
    stnAddr1 VARCHAR(40),
    stnAddr2 VARCHAR(40),
    stnPostalCode VARCHAR(10),
    stnCity VARCHAR(40),
    stnState CHAR(2),
    stnCountry CHAR(2),

    PRIMARY KEY (stnId),

    FOREIGN KEY (stnAcct)
        REFERENCES sys_customer_account(naId)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Store the data for the various types of requirements,
-- E.g. PO, Unit Number, Location Code
CREATE TABLE doc_req(
    reKeyWord CHAR(3), -- ShortHand, E.g. Location code could be shortened to EO3 / Whatever
    reShortDesc VARCHAR(40), -- The label that will be used in the <label> element
    reId VARCHAR(20), -- The id/name that the <input> element will be assigned
    reHasHelp BOOLEAN, -- Toggle the requirement mask for this requirement
    reHelpURL VARCHAR(15), -- Eventually, reference an inline help article by clicking on ?

    PRIMARY KEY (reKeyWord)
);

CREATE TABLE doc_req_accept (
    ravId CHAR(36) NOT NULL, -- Unique indentifier for each value in the mask
    ravMask VARCHAR(40), -- NXAB mask
    ravValue VARCHAR(40) NOT NULL, -- Actual value
    ravKeyWord CHAR(3) NOT NULL, -- Keyword to match up with the requirementElements
    ravAcct CHAR(36) NOT NULL, -- NA/GA associated with the requirement
    ravNonsig CHAR(36), -- Optional nonsig

    PRIMARY KEY (ravId),

    FOREIGN KEY (ravKeyWord)
        REFERENCES requirementElements(reKeyWord)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (ravAcct)
        REFERENCES sys_customer_account(naId)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (ravNonsig)
        REFERENCES sys_addr_ship(stnId)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Store the attributes for the requirements
-- Since these are <input> attributes, I don't expect any huge chunks of data
-- to be stored here. The largest would probably be the placeholder attribute. 
CREATE TABLE doc_req_attr (
    raKey INT(7) NOT NULL AUTO_INCREMENT, -- Nonsignificant, unique key
    raKeyWord CHAR(3), -- Link to requirements.keyWord
    raAttributeName VARCHAR(20), -- HTML attribute name
    raAttributeValue VARCHAR(100), -- HTML attribute value

    PRIMARY KEY (raKey),
    
    FOREIGN KEY (raKeyword) -- Use the keyword to find the attributes for that input
        REFERENCES requirementElements(reKeyWord)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- Store any MDSE that is excluded from a national account
CREATE TABLE doc_prod_accept (
    dmId INT NOT NULL AUTO_INCREMENT,
    dmAcct CHAR(36),
    dmShipToNonsig CHAR(36),
    dmDept INT(3),
    dmCode INT(9),
    dmRangeFrom INT(9),
    dmRangeTo INT(9),

    PRIMARY KEY (dmId),

    FOREIGN KEY (dmAcct)
        REFERENCES sys_customer_account(naId)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (dmShipToNonsig)
        REFERENCES sys_addr_shop=(stnId)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE sys_db_object (
	PRIMARY KEY(sys_id),
    sys_id CHAR(36),
	name VARCHAR(40) NOT NULL, -- Name of the table
	label VARCHAR(40) NOT NULL, -- Friendly name
	description VARCHAR(80) -- Short Description
) CHARSET = utf8;

CREATE TABLE sys_db_dictionary (
	PRIMARY KEY(sys_id),
    sys_id CHAR(36), -- Primary key used for linking to other fields 
    reference_id CHAR(36), -- Foreign key used to reference other fields
	column_name VARCHAR(40),
    visible BOOLEAN NOT NULL DEFAULT 1, -- Whether the field shows up on a form or not, overridden by admin_view flag
    admin_view BOOLEAN NOT NULL DEFAULT 0, -- Whether the field can be exposed on the API or not
    readonly BOOLEAN NOT NULL DEFAULT 0,
	label VARCHAR(40), -- Friendly name
	hint VARCHAR(40), -- Popup hint
	type VARCHAR(10), -- Type (boolean, varchar, char, etc...)
	length INT, -- Length of field, applies to varchar, char
	table_name CHAR(36),

	FOREIGN KEY(table_name)
		REFERENCES sys_db_object (sys_id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
    FOREIGN KEY (reference_id)
        REFERENCES sys_db_dictionary (sys_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) CHARSET = utf8;

CREATE TABLE sys_db_acl (
	PRIMARY KEY(dbpriv, dbtable),
	dbpriv VARCHAR(36),
	dbtable CHAR(36),
	dbcreate BOOLEAN DEFAULT 0 NOT NULL, -- Whether the dbpriv can create
	dbread BOOLEAN DEFAULT 0 NOT NULL, -- Whether the dbpriv can read
	dbupdate BOOLEAN DEFAULT 0 NOT NULL, -- etc
	dbdelete BOOLEAN DEFAULT 0 NOT NULL,
	FOREIGN KEY (dbtable)
		REFERENCES sys_db_object (sys_id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY (dbpriv)
		REFERENCES sys_navigation (navPriv)
		ON DELETE CASCADE
		ON UPDATE CASCADE
) CHARSET = utf8;

CREATE TABLE sys_log (
	PRIMARY KEY(log_key),
    log_key INT AUTO_INCREMENT,
	log_time DATETIME DEFAULT CURRENT_TIMESTAMP(),
	log_message VARCHAR(100),
	log_severity INT(1) DEFAULT 3
);

CREATE TABLE sys_log_user AS SELECT * FROM sys_log;
ALTER TABLE sys_log_user ADD COLUMN log_user CHAR(36) NOT NULL;

CREATE TABLE sys_authorization (
    PRIMARY KEY(auth_priv, auth_table),
    auth_priv VARCHAR(36) NOT NULL,
    auth_table VARCHAR(40),
    auth_can_create BOOLEAN,
    auth_can_read BOOLEAN,
    auth_can_edit BOOLEAN,
    auth_can_delete BOOLEAN,

    FOREIGN KEY (auth_priv)
        REFERENCES sys_priv(priv)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Store custom views
CREATE VIEW 
    thq.uiNavigation
AS
    SELECT
        CONCAT( sys_navigation.navPathName, '?', IFNULL(sys_navigation.navQueryString, '')) AS navHref,    
        sys_navigation.navInnerText,
        sys_navigation.navHeader,
        sys_navigation.navMenu,
        sys_navigation.navIsNotApi,
        sys_role.rpId
    FROM 
        sys_role
    INNER JOIN
        sys_navigation
    ON
        sys_navigation.navPriv = sys_role.rpPriv
    WHERE 
        navIsNotApi = 1
    AND
        navActive = 1
    ORDER BY
        navMenu, navInnerText;

CREATE VIEW
    thq.userLogin
AS
    SELECT
        sys_user.userId,
        sys_user.userName, 
        sys_user.userPass,
        sys_user.userEmail,
        sys_user.userIsConfirmed,
        sys_user.userIsLocked,
        sys_user.userInvalidLoginAttempts,
        sys_user.userDefaultNonsig AS userNonsig,
        sys_customer.nsIsActive,
        sys_user_nsacl.nsaNonsig,
        sys_user_nsacl.nsaRole AS userRole,
        sys_user_nsacl.nsaUserId
    FROM
        sys_user
    INNER JOIN
        sys_customer
    ON
        sys_customer.nsNonsig = sys_user.userDefaultNonsig
    INNER JOIN
        sys_user_nsacl
    ON
        sys_user_nsacl.nsaNonsig = sys_user.userDefaultNonsig
    AND
        sys_user_nsacl.nsaUserId = sys_user.userId;


CREATE VIEW users
AS
    SELECT
        sys_user.userId,
        sys_user.userName,
        sys_user.userEmail,
        sys_user.userIsLocked,
        sys_user.userIsConfirmed,
        sys_user.userDefaultNonsig,
        userInformation.userId AS userInfo,
        userInformation.userLastLogin,
        userInformation.userFirstName,
        userInformation.userLastName,
        userInformation.userPhone
    FROM
        sys_user
    INNER JOIN
        userInformation
    ON
        sys_user.userId = userInformation.userId;
