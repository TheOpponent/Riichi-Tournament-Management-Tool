# Mahjong Tournament Tool

This is a tournament management tool specifically designed for riichi mahjong,
built using Godot 4, with the goal of supporting dynamic pairings, specifically
the "Progressive Swiss" system designed by Edwin D. from the Seattle mahjong
club, though it does support other tournament styles as well.

## Planned Features
It should be possible to create tournaments with any combination of typical
scoring features.

While a tournament is in-progress, it should be possible to:

* Input scores for tables that have finished playing and automatically calculate
  cumulative player scores and resultant rankings.
  * Score input should support verifying that the total score of all players
    is inputted correctly based on the total starting score per table, and
    should support the issuance of penalties by judges or other event staff.
* Generate pairings for the next tournament round, with the pairing generation
  strategy defined by the tournament's settings.
  * By default, the software will attempt to generate a table for each
    registered players will each round, though it should be possible to generate
    tables for only a selected subset of players instead.
  * If necessary, tables may be created on an ad-hoc basis, which is useful for
    tournaments without a fixed number of rounds (e.g. the RNNYC online or
    Sunday in-person meetups).
* Cut to the Top X players, with options for modifying those players' cumulative
  scores (e.g. cleared, halved, unchanged).
* Edit scores of previously submitted games in case of clerical or other error.
* Permit players to drop from the tournament, and alert the tournament organizer
  if substitute players are required (due to not having enough players for a
  full table) and if so, the total number of substitutes required.
  * If enough players drop from the event, the number of tables playing should
    be automatically decreased.
  * The tournament organizer may also proceed without substitutes, in which case
    players will be randomly chosen to sit out.
* Keep track of when a round was started, and provide a graphical timer that
  can be displayed to players so they know how much play time remains for that
  round.

This tool will use Godot's native tools to generate save files, which will allow
the tournament organizer to load a tournament's state from a save file for
convenience. The software should have an auto-save feature that automatically
saves the most recent edits to ensure data integrity as much as possible.

* As a future feature, we intend to allow the software to interface with Google
  Sheets using an organizer-supplied API key.
  * This can allow players to view the current standings and the generated
    pairings for the next round without having direct access to the software
    themselves.
  * Ideally it should also be possible to export and import all data associated
    with the tournament to and from Google Sheets. This allows tournament
    organizers to hedge against hard drive failure or other potential data loss
    issues.
  * For convenience, the software should generate a QR code linking to the
    public spreadsheet in a separate window that can then be displayed publicly.

## Caveats
* The progressive swiss pairing system only attempts to resolve duplicate
  pairings within a single swiss block. In tournaments where the number of
  hanchan played is large relative to the size of the block, it is possible that 
  no suitable pairing can be found. In those cases the we leave initial pairings
  in place.

## Roadmap for v1.0 Release
* Allow players to be deleted on the tournament creation screen.
* Allow deletion of erroneously created players, rounds, or tables in the main
  tournament management interface
* Add integration with Google Sheets for importing/exporting tournament data.

## Contributing
This fork has been updated from Godot 4.2 to Godot 4.6 stable (released 26 
January 2026). Clone this repository and open in Godot 4.6 or later.
