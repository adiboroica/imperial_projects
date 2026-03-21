import { Progress } from "@mantine/core";
import { showNotification, updateNotification } from "@mantine/notifications";
import { IconAlertTriangle, IconCheck } from '@tabler/icons';
import { LoadingType } from "../../../utils/graph/types";


export const displayLoadingNotification = (loadingType: LoadingType | null) => {
  if (loadingType === null) {
    return;
  }

  const typeMessage = new Map<LoadingType, string>([
    [LoadingType.GenerateParagraph, "Generating paragraph."],
    [LoadingType.GenerateActions, "Generating actions."],
    [LoadingType.GenerateEnding, "Generating ending."],
    [LoadingType.ConnectingNodes, "Connecting nodes."],
    [LoadingType.InitialStory, "Generating initial story."],
    [LoadingType.GenerateMany, "Generating many paragraphs and actions."],
    [LoadingType.SaveName, "Updating Story Title."],
    [LoadingType.SaveStory, "Saving current story and graph."],
    [LoadingType.GenerateNewAction, "Generating new action."]
  ]);
  const message = typeMessage.get(loadingType);

  showNotification({
    id: 'load-data',
    loading: true,
    title: message,
    message: 'Please wait.',
    autoClose: false,
    disallowClose: true,
  });
}


export const displayLoadedNotification = (loadingType: LoadingType | null) => {
  if (loadingType === null) {
    return;
  }

  const typeMessage = new Map<LoadingType, string>([
    [LoadingType.GenerateParagraph, "Paragraph was generated successfully."],
    [LoadingType.GenerateActions, "Actions were generated successfully."],
    [LoadingType.GenerateEnding, "Ending was generated successfully."],
    [LoadingType.ConnectingNodes, "Nodes were successfully connected."],
    [LoadingType.InitialStory, "Initial story was generated successfully."],
    [LoadingType.GenerateMany, "Many paragraphs and actions were generated successfully."],
    [LoadingType.SaveName, "Updated Story Title."],
    [LoadingType.SaveStory, "Saved current story and graph successfully."],
    [LoadingType.GenerateNewAction, "Action was generated successfully."]
  ]);
  const message = typeMessage.get(loadingType);

  updateNotification({
    id: 'load-data',
    color: 'teal',
    title: message,
    message: 'You can close this notification now.',
    icon: <IconCheck size={16} />,
    autoClose: 1500,
  });
}


export const displayErrorUpdate = (title: string, message: string='Try again...') => {
  updateNotification({
    id: 'load-data',
    color: 'red',
    title,
    message,
    icon: <IconAlertTriangle size={16} />,
    autoClose: 2000,
  });
}


export type LoadingUpdate = {
  percentage: number,
  numNodesGenerated: number,
}
export const displayGenerateManyUpdate = (loadingUpdate: LoadingUpdate) => {
  updateNotification({
    id: 'load-data',
    loading: true,
    title: "Generating many paragraphs and actions.",
    message: <Progress value={loadingUpdate.percentage} />,
    autoClose: false,
    disallowClose: true,
  });
};
export const displayGenerateManyLoadingNotification = () => {
  showNotification({
    id: 'load-data',
    loading: true,
    title: "Generating many paragraphs and actions.",
    message: <Progress value={0} />,
    autoClose: false,
    disallowClose: true,
  });
};
