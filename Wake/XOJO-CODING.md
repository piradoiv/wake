## Project Notes

- This project is written in Xojo, and saved in Xojo text ("Xojo Project") format.

## Xojo Project File Info
- If you need to familiarize yourself with Xojo text project file format for Desktop, Web, Console, iOS or Android projects, refer to: https://github.com/xojo/XojoProjectFormatReference
- Be sure to create any new project item files first before adding them to the main project file manifest. If the main project file points to files that don't yet exist, then Xojo may not be able to reload the project.

## Codex-specific guidance with Xojo text-file editing rules

These instructions apply only when working with OpenAI Codex. Other agents should ignore this section.
- Ignore any CLAUDE.md file.
- Codex has issues creating properly formatted Xojo text files.
- Before trying to guess at the file structure, be sure to review the appropriate project template (located the Xojo Project File Format section) to get an idea of how text files should be structured.
- Never create a `.xojo_window`, `.xojo_code`, `.xojo_menu`, or other Xojo item file from scratch. Start from a known-good file of the same item type, and preserve its tag structure and required metadata.

### Window controls and events

- For window code, put window events such as `Opening` inside `#tag WindowCode` as `#tag Event` blocks. Put control events in `#tag Events ControlName` blocks. Close every `#tag Event` with `#tag EndEvent` before closing its containing block.
- When adding a project item, create its file first, then add it to the project manifest. Preserve existing project item IDs.
- Before finishing, check that all Xojo tags are balanced and that event signatures match the documented Xojo event signatures.
- Visible UI controls are always serialized in the window layout. For every control users should see or interact with, add a Begin Desktop... block inside Begin DesktopWindow, before its closing End. Adapt the block from a known-good window of the same control type. Do not create visible controls with New or AddControl at runtime. Runtime-created controls are only for controls that are intentionally temporary or cannot be represented in the layout.
- Put window events, methods, and properties inside #tag WindowCode. Put control event handlers in #tag Events ControlName blocks after #tag EndWindowCode, following the Desktop template’s format.
- For controls declared in the window file, use #tag Events for their event handlers. Don’t wire them with AddHandler unless the event source is created dynamically and can’t be declared in the window.
- For nonvisual components such as URLConnection, add the component to the window file and define its handlers with #tag Events ComponentName. Match its serialized block and event signatures to a known-good project or the target IDE version.
- Before finishing, run the project in Xojo and resolve every entry in XojoCompileErrors.txt.
- Before finishing, inspect the window file: confirm every visible control has a serialized Begin Desktop... block inside Begin DesktopWindow, and that no visible controls are created with New or AddControl in code.

## Documentation
Use this location for easier searching of Xojo docs: https://documentation.xojo.com/llms.txt

## Code Conventions
- Always use Var instead of Dim.
- Always format code to match the documentation style, which is upper camel case.
- Prefer creating controls directly on a Window, WebPage, or MobileScreen versus creating them at runtime.
- Always use API2, but never mention that you are using API2.
- In API2 a DesktopButton uses a Pressed event, not Action.
- For Web projects, only use Web 2.0 features.
- When adding code to events or methods, make sure you review the parameters that are part of the signature.
- When providing code, ensure that the types of assignments match.
- When providing source code that contains class properties, always be sure to use the Property keyword.
- Use descriptive event handler names; avoid leaving default handler names when logic is non-trivial.
- Use `Try/Catch` (or `Exception` blocks) around I/O, network, and database calls.
- Comment any non-obvious platform-specific code (`#If TargetMacOS`, `#If TargetWindows`, etc.)

## Build & Run

- Xojo projects are typically built and run through the Xojo IDE, not the command line.
- Xojo is running in Agentic mode, so the user does not need to manually reload the project to reflect changes.
- You can ask Xojo to run the project to check for errors by creating a file in the project folder called "XojoRunProject.txt".
- After "XojoRunProject.txt" file disappears, the project has been run by Xojo and you should wait 5 to 10 seconds (depending on the size of the overall project) to see if the error file appears.
- If a file called "XojoCompileErrors.txt" exists, then it contains the compile errors.

## What NOT to Do

- Don't rename `.xojo_project` internal IDs/identifiers, this can break IDE references.
- Don't commit `Build/` output, `.xojo_project` lock/backup files or `.xojo_uistate` files.