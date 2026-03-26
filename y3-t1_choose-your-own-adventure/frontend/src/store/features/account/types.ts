import StatusCode from "status-code-enum"


export type StoryListEntry = {
  name: string,
  storyId: string,
  firstParagraph: string,
  totalSections: number,
}

export type AuthResponse = {
  email?: string,
  status: StatusCode,
}