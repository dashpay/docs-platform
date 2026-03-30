```{eval-rst}
.. _protocol-ref-errors:
```

# Consensus Errors

## Platform Error Codes

Dash Platform Protocol implements a comprehensive set of consensus error codes. Refer to the tables below for a list of the codes as specified in [code.rs](https://github.com/dashpay/platform/blob/v2.0.1/packages/rs-dpp/src/errors/consensus/codes.rs) of the consensus source code.

Platform error codes are organized into four categories. Each category may be further divided into sub-categories. The four categories and their error code ranges are:

| Category                       |  Code range | Description |
| ------------------------------ | :---------: | ----------- |
| [Basic](#basic-errors)                | 10000 - 10999 | Errors encountered while validating structure and data |
| [Signature](#signature-errors) | 20000 - 20999 | Errors encountered while validating identity existence and state transition signature |
| [Fee](#fee-errors)             | 30000 - 30999 | Errors encountered while validating an identity's balance is sufficient to pay fees |
| [State](#state-errors)         | 40000 - 40999 | Errors encounter while validating state transitions against the platform state |

## Basic Errors

Basic errors occupy the codes ranging from 10000 to 10999. This range is divided into several categories for clarity.

### Versioning

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

### Structure

Code range:  10100-10199

| Code  | Error Description             | Comment |
| :---: | ----------------------------- | ------- |
| 10100 | JsonSchemaCompilationError    |         |
| 10101 | JsonSchemaError               |         |
| 10102 | InvalidIdentifierError        |         |
| 10103 | ValueError                    |         |

### Data Contract

Code range:  10200-10349

| Code  | Error Description                               | Comment |
| :---: | ----------------------------------------------- | ------- |
| 10200 | DataContractMaxDepthExceedError                 |         |
| 10201 | DuplicateIndexError                             |         |
| 10202 | IncompatibleRe2PatternError                     |         |
| 10203 | InvalidCompoundIndexError                       |         |
| 10204 | InvalidDataContractIdError                      |         |
| 10205 | InvalidIndexedPropertyConstraintError           |         |
| 10206 | InvalidIndexPropertyTypeError                   |         |
| 10207 | InvalidJsonSchemaRefError                       |         |
| 10208 | SystemPropertyIndexAlreadyPresentError          |         |
| 10209 | UndefinedIndexPropertyError                     |         |
| 10210 | UniqueIndicesLimitReachedError                  |         |
| 10211 | DuplicateIndexNameError                         |         |
| 10212 | InvalidDataContractVersionError                 |         |
| 10213 | IncompatibleDataContractSchemaError             |         |
| 10214 | DocumentTypesAreMissingError                    |         |
| 10215 | DataContractImmutablePropertiesUpdateError      |         |
| 10216 | DataContractUniqueIndicesChangedError           |         |
| 10217 | DataContractInvalidIndexDefinitionUpdateError   |         |
| 10218 | DataContractHaveNewUniqueIndexError             |         |
| 10219 | InvalidDocumentTypeRequiredSecurityLevelError   |         |
| 10220 | UnknownSecurityLevelError                       |         |
| 10221 | UnknownStorageKeyRequirementsError              |         |
| 10222 | DecodingContractError                           |         |
| 10223 | DecodingDocumentError                           |         |
| 10224 | InvalidDocumentTypeError                        |         |
| 10225 | MissingRequiredKey                              |         |
| 10226 | FieldRequirementUnmet                           |         |
| 10227 | KeyWrongType                                    |         |
| 10228 | ValueWrongType                                  |         |
| 10229 | ValueDecodingError                              |         |
| 10230 | EncodingDataStructureNotSupported               |         |
| 10231 | InvalidContractStructure                        |         |
| 10232 | DocumentTypeNotFound                            |         |
| 10233 | DocumentTypeFieldNotFound                       |         |
| 10234 | ReferenceDefinitionNotFound                     |         |
| 10235 | DocumentOwnerIdMissing                          |         |
| 10236 | DocumentIdMissing                               |         |
| 10237 | Unsupported                                     |         |
| 10238 | CorruptedSerialization                          |         |
| 10239 | JsonSchema                                      |         |
| 10240 | InvalidURI                                      |         |
| 10241 | KeyWrongBounds                                  |         |
| 10242 | KeyValueMustExist                               |         |
| 10243 | UnknownTransferableTypeError                    |         |
| 10244 | UnknownTradeModeError                           |         |
| 10245 | UnknownDocumentCreationRestrictionModeError     |         |
| 10246 | IncompatibleDocumentTypeSchemaError             |         |
| 10247 | RegexError                                      |         |
| 10248 | ContestedUniqueIndexOnMutableDocumentTypeError  |         |
| 10249 | ContestedUniqueIndexWithUniqueIndexError        |         |
| 10250 | DataContractTokenConfigurationUpdateError       |         |
| 10251 | InvalidTokenBaseSupplyError                     |         |
| 10252 | NonContiguousContractGroupPositionsError        |         |
| 10253 | NonContiguousContractTokenPositionsError                  |         |
| 10254 | InvalidTokenDistributionFunctionDivideByZeroError        |         |
| 10255 | InvalidTokenDistributionFunctionInvalidParameterError    |         |
| 10256 | InvalidTokenDistributionFunctionInvalidParameterTupleError |       |
| 10257 | InvalidTokenDistributionFunctionIncoherenceError         |         |
| 10258 | MissingDefaultLocalizationError                          |         |
| 10259 | UnknownGasFeesPaidByError                                |         |
| 10260 | UnknownDocumentActionTokenEffectError                    |         |
| 10261 | TokenPaymentByBurningOnlyAllowedOnInternalTokenError     |         |
| 10262 | TooManyKeywordsError                                     |         |
| 10263 | DuplicateKeywordsError                                   |         |
| 10264 | InvalidDescriptionLengthError                            |         |
| 10265 | NewTokensDestinationIdentityOptionRequiredError          |         |
| 10266 | InvalidTokenNameCharacterError                           |         |
| 10267 | InvalidTokenNameLengthError                              |         |
| 10268 | InvalidTokenLanguageCodeError                            |         |
| 10269 | InvalidKeywordCharacterError                             |         |
| 10270 | InvalidKeywordLengthError                                |         |
| 10271 | DecimalsOverLimitError                                   |         |
| 10272 | InvalidTokenDistributionBlockIntervalTooShortError       |         |
| 10273 | InvalidTokenDistributionTimeIntervalTooShortError        |         |
| 10274 | InvalidTokenDistributionTimeIntervalNotMinuteAlignedError |        |
| 10275 | RedundantDocumentPaidForByTokenWithContractId            |         |

### Group

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
| 10357 |MainGroupIsNotDefinedError                                |         |
| 10358 |GroupRequiredPowerIsInvalidError                           |         |
| 10359 |GroupHasTooFewMembersError                                 |         |

### Document

Code range:  10400-10449

| Code  | Error Description                                    | Comment |
| :---: | ---------------------------------------------------- | ------- |
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

### Token

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
| 10457 | InvalidTokenConfigUpdateNoChangeError                  |         |
| 10458 | InvalidTokenAmountError                                |         |
| 10459 | InvalidTokenNoteTooBigError                            |         |
| 10460 | TokenNoteOnlyAllowedWhenProposerError                  |         |

### Identity

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
| 10533 | InvalidKeyPurposeForContractBoundsError                       |         |

### State Transition

Code range:  10600-10699

| Code  | Error Description                   | Comment |
| :---: | ----------------------------------- | ------- |
| 10600 | InvalidStateTransitionTypeError     |         |
| 10601 | MissingStateTransitionTypeError     |         |
| 10602 | StateTransitionMaxSizeExceededError |         |
| 10603 | StateTransitionNotActiveError      |         |

### General

Code range:  10700-10799

| Code  | Error Description   | Comment |
| ----- | ------------------- | ------- |
| 10700 | OverflowError       |         |

### Address

Code range: 10800-10899

| Code  | Error Description                              | Comment |
| :---: | ---------------------------------------------- | ------- |
| 10800 | TransitionOverMaxInputsError                   |         |
| 10801 | TransitionOverMaxOutputsError                  |         |
| 10802 | InputWitnessCountMismatchError                 |         |
| 10803 | TransitionNoInputsError                        |         |
| 10804 | TransitionNoOutputsError                       |         |
| 10805 | FeeStrategyEmptyError                          |         |
| 10806 | FeeStrategyDuplicateError                      |         |
| 10807 | FeeStrategyIndexOutOfBoundsError               |         |
| 10808 | FeeStrategyTooManyStepsError                   |         |
| 10809 | InputBelowMinimumError                         |         |
| 10810 | OutputBelowMinimumError                        |         |
| 10811 | InputOutputBalanceMismatchError                |         |
| 10812 | OutputsNotGreaterThanInputsError               |         |
| 10813 | WithdrawalBalanceMismatchError                 |         |
| 10814 | InsufficientFundingAmountError                 |         |
| 10815 | InputsNotLessThanOutputsError                  |         |
| 10816 | OutputAddressAlsoInputError                    |         |
| 10817 | InvalidRemainderOutputCountError               |         |
| 10818 | WithdrawalBelowMinAmountError                  |         |
| 10819 | ShieldedNoActionsError                         |         |
| 10820 | ShieldedEmptyProofError                        |         |
| 10821 | ShieldedZeroAnchorError                        |         |
| 10822 | ShieldedInvalidValueBalanceError               |         |
| 10825 | ShieldedTooManyActionsError                    |         |

## Signature Errors

| Code  | Error Description                           | Comment        |
| :---: | ------------------------------------------- | -------------- |
| 20000 | IdentityNotFoundError                       |                |
| 20001 | InvalidIdentityPublicKeyTypeError           |                |
| 20002 | InvalidStateTransitionSignatureError        |                |
| 20003 | MissingPublicKeyError                       |                |
| 20004 | InvalidSignaturePublicKeySecurityLevelError |                |
| 20005 | WrongPublicKeyPurposeError                  |                |
| 20006 | PublicKeyIsDisabledError                    |                |
| 20007 | PublicKeySecurityLevelNotMetError           |                |
| 20008 | SignatureShouldNotBePresentError            |                |
| 20009 | BasicECDSAError                             |                |
| 20010 | BasicBLSError                               |                |
| 20011 | InvalidSignaturePublicKeyPurposeError       |                |
| 20012 | UncompressedPublicKeyNotAllowedError        |                |

## Fee Errors

| Code  | Error Description       | Comment                                            |
| :---: | ----------------------- | -------------------------------------------------- |
| 30000 | BalanceIsNotEnoughError | Current credits balance is insufficient to pay fee |

## State Errors

### Data Contract State

Code range:  40000-40099

| Code  | Error Description                       | Comment |
| :---: | --------------------------------------- | ------- |
| 40000 | DataContractAlreadyPresentError         |         |
| 40001 | DataContractIsReadonlyError             |         |
| 40002 | DataContractConfigUpdateError           |         |
| 40003 | DataContractUpdatePermissionError       |         |
| 40004 | DataContractUpdateActionNotAllowedError |         |
| 40005 | PreProgrammedDistributionTimestampInPastError    |         |
| 40006 | IdentityInTokenConfigurationNotFoundError        |         |
| 40007 | IdentityMemberOfGroupNotFoundError               |         |
| 40008 | DataContractNotFoundError                        |         |
| 40009 | InvalidTokenPositionStateError                   |         |

### Document State

Code range:  40100-40149

| Code  | Error Description                                      | Comment |
| :---: | ------------------------------------------------------ | ------- |
| 40100 | DocumentAlreadyPresentError                            |         |
| 40101 | DocumentNotFoundError                                  |         |
| 40102 | DocumentOwnerIdMismatchError                           |         |
| 40103 | DocumentTimestampsMismatchError                        |         |
| 40104 | DocumentTimestampWindowViolationError                  |         |
| 40105 | DuplicateUniqueIndexError                              |         |
| 40106 | InvalidDocumentRevisionError                           |         |
| 40107 | DocumentTimestampsAreEqualError                        |         |
| 40108 | DocumentNotForSaleError                                |         |
| 40109 | DocumentIncorrectPurchasePriceError                    |         |
| 40110 | DocumentContestCurrentlyLockedError                    |         |
| 40111 | DocumentContestNotJoinableError                        |         |
| 40112 | DocumentContestIdentityAlreadyContestantError          |         |
| 40113 | DocumentContestDocumentWithSameIdAlreadyPresentError   |         |
| 40114 | DocumentContestNotPaidForError                         |         |
| 40115 | RequiredTokenPaymentInfoNotSetError                    |         |
| 40116 | IdentityHasNotAgreedToPayRequiredTokenAmountError      |         |
| 40117 | IdentityTryingToPayWithWrongTokenError                 |         |

### Token State

Code range: 40700-40799

| Code  | Error Description                                      | Comment |
| :---: | ------------------------------------------------------ | ------- |
| 40700 | IdentityDoesNotHaveEnoughTokenBalanceError             |         |
| 40701 | UnauthorizedTokenActionError                           |         |
| 40702 | IdentityTokenAccountFrozenError                        |         |
| 40703 | IdentityTokenAccountNotFrozenError                     |         |
| 40704 | TokenSettingMaxSupplyToLessThanCurrentSupplyError      |         |
| 40705 | TokenMintPastMaxSupplyError                            |         |
| 40706 | NewTokensDestinationIdentityDoesNotExistError          |         |
| 40707 | NewAuthorizedActionTakerIdentityDoesNotExistError      |         |
| 40708 | NewAuthorizedActionTakerGroupDoesNotExistError         |         |
| 40709 | NewAuthorizedActionTakerMainGroupNotSetError           |         |
| 40710 | InvalidGroupPositionError                              |         |
| 40711 | TokenIsPausedError                                     |         |
| 40712 | IdentityTokenAccountAlreadyFrozenError                 |         |
| 40713 | TokenAlreadyPausedError                                |         |
| 40714 | TokenNotPausedError                                    |         |
| 40715 | InvalidTokenClaimPropertyMismatch                      |         |
| 40716 | InvalidTokenClaimNoCurrentRewards                      |         |
| 40717 | InvalidTokenClaimWrongClaimant                         |         |
| 40718 | TokenTransferRecipientIdentityNotExistError            |         |
| 40719 | TokenDirectPurchaseUserPriceTooLow                     |         |
| 40720 | TokenAmountUnderMinimumSaleAmount                      |         |
| 40721 | TokenNotForDirectSale                                  |         |

### Identity State

Code range:  40200-40299

| Code  | Error Description                                          | Comment |
| :---: | ---------------------------------------------------------- | ------- |
| 40200 | IdentityAlreadyExistsError                                 |         |
| 40201 | IdentityPublicKeyIsReadOnlyError                           |         |
| 40202 | InvalidIdentityPublicKeyIdError                            |         |
| 40203 | InvalidIdentityRevisionError                               |         |
| 40204 | InvalidIdentityNonceError                                  |         |
| 40205 | MaxIdentityPublicKeyLimitReachedError                      |         |
| 40206 | DuplicatedIdentityPublicKeyStateError                      |         |
| 40207 | DuplicatedIdentityPublicKeyIdStateError                    |         |
| 40208 | IdentityPublicKeyIsDisabledError                           |         |
| 40209 | MissingIdentityPublicKeyIdsError                           |         |
| 40210 | IdentityInsufficientBalanceError                           |         |
| 40211 | IdentityPublicKeyAlreadyExistsForUniqueContractBoundsError |         |
| 40212 | DocumentTypeUpdateError                                    |         |
| 40214 | MissingTransferKeyError                                    |         |
| 40215 | NoTransferKeyForCoreWithdrawalAvailableError               |         |
| 40216 | RecipientIdentityDoesNotExistError                         |         |
| 40217 | IdentityToFreezeDoesNotExistError                          |         |

### Voting State

Code range:  40300-40399

| Code  | Error Description                       | Comment |
| :---: | --------------------------------------- | ------- |
| 40300 | MasternodeNotFoundError                 |         |
| 40301 | VotePollNotFoundError                   |         |
| 40302 | VotePollNotAvailableForVotingError      |         |
| 40303 | MasternodeVotedTooManyTimesError        |         |
| 40304 | MasternodeVoteAlreadyPresentError       |         |
| 40305 | MasternodeIncorrectVotingAddressError   |         |
| 40306 | MasternodeIncorrectVoterIdentityIdError |         |

### Prefunded Specialized Balances State

Code range: 40400-40499

| Code  | Error Description                            | Comment |
| :---: | -------------------------------------------- | ------- |
| 40400 | PrefundedSpecializedBalanceInsufficientError |         |
| 40401 | PrefundedSpecializedBalanceNotFoundError     |         |

### Data Trigger State

Code range: 40500-40799

| Code  | Error Description             | Comment |
| :---: | ----------------------------- | ------- |
| 40500 | DataTriggerConditionError     |         |
| 40501 | DataTriggerExecutionError     |         |
| 40502 | DataTriggerInvalidResultError |         |

### Address State

Code range: 40600-40699

| Code  | Error Description               | Comment |
| :---: | ------------------------------- | ------- |
| 40600 | AddressDoesNotExistError        |         |
| 40601 | AddressNotEnoughFundsError      |         |
| 40602 | AddressesNotEnoughFundsError    |         |
| 40603 | AddressInvalidNonceError        |         |

### Group State

Code range: 40800-40899

| Code  | Error Description                       | Comment |
| :---: | --------------------------------------- | ------- |
| 40800 | IdentityNotMemberOfGroupError           |         |
| 40801 | GroupActionDoesNotExistError            |         |
| 40802 | GroupActionAlreadyCompletedError        |         |
| 40803 | GroupActionAlreadySignedByIdentityError |         |
| 40804 | ModificationOfGroupActionMainParametersNotPermittedError |         |

### Shielded State

Code range: 40900-40999

| Code  | Error Description               | Comment |
| :---: | ------------------------------- | ------- |
| 40900 | InvalidAnchorError              |         |
| 40901 | NullifierAlreadySpentError      |         |
| 40902 | InvalidShieldedProofError       |         |
| 40903 | InsufficientPoolNotesError      |         |
| 40904 | InsufficientShieldedFeeError    |         |
