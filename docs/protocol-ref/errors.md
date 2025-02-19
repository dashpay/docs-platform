```{eval-rst}
.. _protocol-ref-errors:
```

# Consensus Errors

## Platform Error Codes

Dash Platform Protocol implements a comprehensive set of consensus error codes. Refer to the tables below for a list of the codes as specified in [code.rs](https://github.com/dashpay/platform/blob/v2.0-dev/packages/rs-dpp/src/errors/consensus/codes.rs) of the consensus source code.

Platform error codes are organized into four categories. Each category may be further divided into sub-categories. The four categories and their error code ranges are:

| Category                       |  Code range | Description |
| ------------------------------ | :---------: | ----------- |
| [Basic](#basic)                | 10000 - 10999 | Errors encountered while validating structure and data |
| [Signature](#signature-errors) | 20000 - 20999 | Errors encountered while validating identity existence and state transition signature |
| [Fee](#fee-errors)             | 30000 - 30999 | Errors encountered while validating an identity's balance is sufficient to pay fees |
| [State](#state)                | 40000 - 40999 | Errors encounter while validating state transitions against the platform state |

## Basic

Basic errors occupy the codes ranging from 10000 to 10999. This range is divided into several categories for clarity.

### Versioning Errors

Code range:  10000-10099

| Code  | Error Description                | Comment |
| :---: | -------------------------------- | ------- |
| 10000 | UnsupportedVersionError          |         |
| 10001 | ProtocolVersionParsingError      |         |
| 10002 | SerializedObjectParsingError     |         |
| 10003 | UnsupportedProtocolVersionError  |         |
| 10004 | IncompatibleProtocolVersionError |         |
| 10005 | VersionError                     |         |
| 10006 | UnsupportedFeatureError          |         |

### Structure Errors

Code range:  10100-10199

| Code  | Error Description             | Comment |
| :---: | ----------------------------- | ------- |
| 10100 | JsonSchemaCompilationError    |         |
| 10101 | JsonSchemaError               |         |
| 10102 | InvalidIdentifierError        |         |
| 10103 | ValueError                    |         |

### Data Contract Errors

Code range:  10200-10399

| Code   | Error Description                               | Comment |
| ------ | ----------------------------------------------- | ------- |
| 10200  | DataContractMaxDepthExceedError                 |         |
| 10201  | DuplicateIndexError                             |         |
| 10202  | IncompatibleRe2PatternError                     |         |
| 10203  | InvalidCompoundIndexError                       |         |
| 10204  | InvalidDataContractIdError                      |         |
| 10205  | InvalidIndexedPropertyConstraintError           |         |
| 10206  | InvalidIndexPropertyTypeError                   |         |
| 10207  | InvalidJsonSchemaRefError                       |         |
| 10208  | SystemPropertyIndexAlreadyPresentError          |         |
| 10209  | UndefinedIndexPropertyError                     |         |
| 10210  | UniqueIndicesLimitReachedError                  |         |
| 10211  | DuplicateIndexNameError                         |         |
| 10212  | InvalidDataContractVersionError                 |         |
| 10213  | IncompatibleDataContractSchemaError             |         |
| 10214  | DocumentTypesAreMissingError                    |         |
| 10215  | DataContractImmutablePropertiesUpdateError      |         |
| 10216  | DataContractUniqueIndicesChangedError           |         |
| 10217  | DataContractInvalidIndexDefinitionUpdateError   |         |
| 10218  | DataContractHaveNewUniqueIndexError             |         |
| 10219  | InvalidDocumentTypeRequiredSecurityLevelError   |         |
| 10220  | UnknownSecurityLevelError                       |         |
| 10221  | UnknownStorageKeyRequirementsError              |         |
| 10222  | DecodingContractError                           |         |
| 10223  | DecodingDocumentError                           |         |
| 10224  | InvalidDocumentTypeError                        |         |
| 10225  | MissingRequiredKey                              |         |
| 10226  | FieldRequirementUnmet                           |         |
| 10227  | KeyWrongType                                    |         |
| 10228  | ValueWrongType                                  |         |
| 10229  | ValueDecodingError                              |         |
| 10230  | EncodingDataStructureNotSupported               |         |
| 10231  | InvalidContractStructure                        |         |
| 10232  | DocumentTypeNotFound                            |         |
| 10233  | DocumentTypeFieldNotFound                       |         |
| 10234  | ReferenceDefinitionNotFound                     |         |
| 10235  | DocumentOwnerIdMissing                          |         |
| 10236  | DocumentIdMissing                               |         |
| 10237  | Unsupported                                     |         |
| 10238  | CorruptedSerialization                          |         |
| 10239  | JsonSchema                                      |         |
| 10240  | InvalidURI                                      |         |
| 10241  | KeyWrongBounds                                  |         |
| 10242  | KeyValueMustExist                               |         |
| 10243  | UnknownTransferableTypeError                    |         |
| 10244  | UnknownTradeModeError                           |         |
| 10245  | UnknownDocumentCreationRestrictionModeError     |         |
| 10246  | IncompatibleDocumentTypeSchemaError             |         |
| 10247  | RegexError                                      |         |
| 10248  | ContestedUniqueIndexOnMutableDocumentTypeError  |         |
| 10249  | ContestedUniqueIndexWithUniqueIndexError        |         |
| 10250  | DataContractTokenConfigurationUpdateError       |         |
| 10251  | InvalidTokenBaseSupplyError                     |         |
| 10252  | NonContiguousContractGroupPositionsError        |         |
| 10253  | NonContiguousContractTokenPositionsError        |         |

### Group Errors

Code range:  10350-10399

| Code  | Error Description                                         | Comment |
| :---: | --------------------------------------------------------- | ------- |
| 10350 |GroupPositionDoesNotExistError                             |         |
| 10351 |GroupActionNotAllowedOnTransitionError                     |         |
| 10352 |GroupTotalPowerLessThanRequiredError                       |         |
| 10353 |GroupNonUnilateralMemberPowerHasLessThanRequiredPowerError |         |
| 10354 |GroupExceedsMaxMembersError                                |         |
| 10355 |GroupMemberHasPowerOfZeroError                             |         |
| 10356 |GroupMemberHasPowerOverLimitError                          |         |

### Document Errors

Code range:  10400-10449

| Code  | Error Description                                    | Comment |
| ----- | ---------------------------------------------------- | ------- |
| 10400 | DataContractNotPresentError                          |         |
| 10401 | DuplicateDocumentTransitionsWithIdsError             |         |
| 10402 | DuplicateDocumentTransitionsWithIndicesError         |         |
| 10403 | InconsistentCompoundIndexDataError                   |         |
| 10404 | InvalidDocumentTransitionActionError                 |         |
| 10405 | InvalidDocumentTransitionIdError                     |         |
| 10406 | InvalidDocumentTypeError                             |         |
| 10407 | MissingDataContractIdBasicError                      |         |
| 10408 | MissingDocumentTransitionActionError                 |         |
| 10409 | MissingDocumentTransitionTypeError                   |         |
| 10410 | MissingDocumentTypeError                             |         |
| 10411 | MissingPositionsInDocumentTypePropertiesError        |         |
| 10412 | MaxDocumentsTransitionsExceededError                 |         |
| 10413 | DocumentTransitionsAreAbsentError                    |         |
| 10414 | NonceOutOfBoundsError                                |         |
| 10415 | InvalidDocumentTypeNameError                         |         |
| 10416 | DocumentCreationNotAllowedError                      |         |
| 10417 | DocumentFieldMaxSizeExceededError                    |         |
| 10418 | ContestedDocumentsTemporarilyNotAllowedError         |         |

### Token Errors

Code range: 10450-10499

| Code  | Error Description                                      | Comment |
| :---: | ------------------------------------------------------ | ------- |
| 10450 | InvalidTokenIdError                                    |         |
| 10451 | InvalidTokenPositionError                              |         |
| 10452 | InvalidActionIdError                                   |         |
| 10453 | ContractHasNoTokensError                               |         |
| 10454 | DestinationIdentityForTokenMintingNotSetError          |         |
| 10455 | ChoosingTokenMintRecipientNotAllowedError              |         |
| 10456 | TokenTransferToOurselfError                            |         |

### Identity Errors

Code range:  10500-10599

| Code  | Error Description                                             | Comment |
| :---: | ------------------------------------------------------------- | ------- |
| 10500 | DuplicatedIdentityPublicKeyBasicError                         |         |
| 10501 | DuplicatedIdentityPublicKeyIdBasicError                       |         |
| 10502 | IdentityAssetLockProofLockedTransactionMismatchError          |         |
| 10503 | IdentityAssetLockTransactionIsNotFoundError                   |         |
| 10504 | IdentityAssetLockTransactionOutPointAlreadyConsumedError      |         |
| 10505 | IdentityAssetLockTransactionOutputNotFoundError               |         |
| 10506 | InvalidAssetLockProofCoreChainHeightError                     |         |
| 10507 | InvalidAssetLockProofTransactionHeightError                   |         |
| 10508 | InvalidAssetLockTransactionOutputReturnSizeError              |         |
| 10509 | InvalidIdentityAssetLockTransactionError                      |         |
| 10510 | InvalidIdentityAssetLockTransactionOutputError                |         |
| 10511 | InvalidIdentityPublicKeyDataError                             |         |
| 10512 | InvalidInstantAssetLockProofError                             |         |
| 10513 | InvalidInstantAssetLockProofSignatureError                    |         |
| 10514 | InvalidIdentityAssetLockProofChainLockValidationError         |         |
| 10515 | DataContractBoundsNotPresentError                             |         |
| 10516 | DisablingKeyIdAlsoBeingAddedInSameTransitionError             |         |
| 10517 | MissingMasterPublicKeyError                                   |         |
| 10518 | TooManyMasterPublicKeyError                                   |         |
| 10519 | InvalidIdentityPublicKeySecurityLevelError                    |         |
| 10520 | InvalidIdentityKeySignatureError                              |         |
| 10521 | InvalidIdentityCreditWithdrawalTransitionOutputScriptError    |         |
| 10522 | InvalidIdentityCreditWithdrawalTransitionCoreFeeError         |         |
| 10523 | NotImplementedIdentityCreditWithdrawalTransitionPoolingError  |         |
| 10524 | InvalidIdentityCreditTransferAmountError                      |         |
| 10525 | InvalidIdentityCreditWithdrawalTransitionAmountError          |         |
| 10526 | InvalidIdentityUpdateTransitionEmptyError                     |         |
| 10527 | InvalidIdentityUpdateTransitionDisableKeysError               |         |
| 10528 | IdentityCreditTransferToSelfError                             |         |
| 10529 | MasterPublicKeyUpdateError                                    |         |
| 10530 | IdentityAssetLockTransactionOutPointNotEnoughBalanceError     |         |
| 10531 | IdentityAssetLockStateTransitionReplayError                   |         |
| 10532 | WithdrawalOutputScriptNotAllowedWhenSigningWithOwnerKeyError  |         |

### State Transition Errors

| Code  | Error Description                   | Comment |
| :---: | ----------------------------------- | ------- |
| 10600 | InvalidStateTransitionTypeError     |         |
| 10601 | MissingStateTransitionTypeError     |         |
| 10602 | StateTransitionMaxSizeExceededError |         |

### General Errors

| Code  | Error Description   | Comment |
| ----- | ------------------- | ------- |
| 10700 | OverflowError       |         |

## Signature Errors

Signature errors occupy the codes ranging from 2000 to 2999.

| Code | Error Description                           | Comment        |
| :--: | ------------------------------------------- | -------------- |
| 2000 | IdentityNotFoundError                       |                |
| 2001 | InvalidIdentityPublicKeyTypeError           |                |
| 2002 | InvalidStateTransitionSignatureError        |                |
| 2003 | MissingPublicKeyError                       |                |
| 2004 | InvalidSignaturePublicKeySecurityLevelError | Added in v0.23 |
| 2005 | WrongPublicKeyPurposeError                  | Added in v0.23 |
| 2006 | PublicKeyIsDisabledError                    | Added in v0.23 |
| 2007 | PublicKeySecurityLevelNotMetError           | Added in v0.23 |

## Fee Errors

Fee errors occupy the codes ranging from 3000 to 3999.

| Code | Error Description       | Comment                                            |
| :--: | ----------------------- | -------------------------------------------------- |
| 3000 | BalanceIsNotEnoughError | Current credits balance is insufficient to pay fee |

## State

State errors occupy the codes ranging from 4000 to 4999. This range is divided into several categories for clarity.

### Data Contract Errors

| Code | Error Description               | Comment |
| :--: | ------------------------------- | ------- |
| 4000 | DataContractAlreadyPresentError |         |

### Document Errors

| Code | Error Description                     | Comment |
| :--: | :------------------------------------ | :------ |
| 4004 | DocumentAlreadyPresentError           |         |
| 4005 | DocumentNotFoundError                 |         |
| 4006 | DocumentOwnerIdMismatchError          |         |
| 4007 | DocumentTimestampsMismatchError       |         |
| 4008 | DocumentTimestampWindowViolationError |         |
| 4009 | DuplicateUniqueIndexError             |         |
| 4010 | InvalidDocumentRevisionError          |         |

### Identity Errors

| Code | Error Description                               | Comment            |
| :--: | ----------------------------------------------- | ------------------ |
| 4011 | IdentityAlreadyExistsError                      |                    |
| 4012 | IdentityPublicKeyDisabledAtWindowViolationError | Added in v0.23     |
| 4017 | IdentityPublicKeyIsReadOnlyError                | Added in v0.23     |
| 4018 | InvalidIdentityPublicKeyIdError                 | Added in v0.23     |
| 4019 | InvalidIdentityRevisionError                    | Added in v0.23     |
| 4020 | StateMaxIdentityPublicKeyLimitReachedError      | Added in v0.23     |
| 4021 | DuplicatedIdentityPublicKeyStateError           | Added in v0.23     |
| 4022 | DuplicatedIdentityPublicKeyIdStateError         | Added in v0.23     |
| 4023 | IdentityPublicKeyIsDisabledError                | Added in v0.23     |
| 4024 | IdentityInsufficientBalanceError                | **Added in v0.24** |

### Data Trigger Errors

| Code | Error Description             | Comment |
| :--: | ----------------------------- | ------- |
| 4001 | DataTriggerConditionError     |         |
| 4002 | DataTriggerExecutionError     |         |
| 4003 | DataTriggerInvalidResultError |         |
