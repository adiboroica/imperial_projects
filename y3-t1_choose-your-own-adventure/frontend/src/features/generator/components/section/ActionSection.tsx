import EditableField from '../../../../components/ui/EditableField';
import classes from './ActionSection.module.css';


interface ActionSectionProps {
  nodeId: number,
  action: string,
};

const ActionSection = (props: ActionSectionProps) => {
  return (
    <EditableField
      value={props.action}
      nodeId={props.nodeId}
      className={classes.action}
    />
  );
};

export default ActionSection;
