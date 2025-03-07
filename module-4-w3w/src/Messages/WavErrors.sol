// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library WavErrors {
    error WavAccess__IndexIssue();
    error WavAccess__NameIsTaken();
    error WavAccess__NotApprovedArtist();
    error WavAccess__IsNotLout();
    //
    error WavToken__IsNotLout();
    error WavToken__CollaboratorSplitLengthMismatch();
    error WavToken__IsNotCollection();
    error WavToken__BitmapOverflow();
    error WavToken__RSaleMismatch();
    error WavToken__RSaleOverflow();
    //
    error WavStore__InsufficientEarnings();
    error WavStore__InsufficientPayment();
    error WavStore__IsNotLout();
    error WavStore__InsufficientTokenSupply();
    error WavStore__ArtistOrContentIdInvalid();
    error WavStore__IsNotCollection();
    error WavStore__IndexIssue();
    error WavStore__PreSaleNotFound();
    error WavStore__PreSaleIsPaused();
    error WavStore__PreSaleNotPaused();
    //
    error WavFortress__InvalidNonce();
    //
    error WavDBC__LengthValIssue();
    error WavDBC__BitValIssue();
}
