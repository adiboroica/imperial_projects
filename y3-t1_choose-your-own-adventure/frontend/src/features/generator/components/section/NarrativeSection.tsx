import { StoryNode } from '../../../../utils/graph/types';
import EditableField from '../../../../components/ui/EditableField';
import classes from './NarrativeSection.module.css';


interface NarrativeSectionProps extends StoryNode { };

const NarrativeSection = (props: NarrativeSectionProps) => {
  return (
    <EditableField
      value={props.paragraph}
      nodeId={props.nodeId}
      className={classes.paragraph}
    />
  );
};

export default NarrativeSection;
