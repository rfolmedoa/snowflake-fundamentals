
-- 19.0.0  APPENDIX

-- 19.1.0  Commonly Used Commands
--         The following commands are used frequently throughout the course.
--         Because of that, they are listed here, rather than repeating them
--         individually for each step that uses them.

-- 19.2.0  File Paths With PUT and GET in Windows
--         Windows file paths changes format if there is a space in the path. It
--         is easier to create a direct path without spaces rather than try and
--         use a path with spaces.
--         Example of a path without spaces. Notice this uses a backslash in the
--         path.

 PUT PUT file://Z:\SnowFlake\region.tbl @loadfiles;


--         Example of a path with spaces. The path must be quoted and it uses a
--         forward slash.

 PUT 'file://Z:/SnowFlake/Fund Training/*.json' @Loadfiles;


