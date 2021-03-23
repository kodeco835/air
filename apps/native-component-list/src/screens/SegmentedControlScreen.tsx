import SegmentedControl from '@react-native-community/segmented-control';
import React, { useState } from 'react';
import { StyleSheet, ScrollView, Text, View } from 'react-native';

// This example is a copy from https://github.com/react-native-community/segmented-control/blob/master/example

const SegmentedControlScreen = () => {
  const [values] = useState(['One', 'Two', 'Three']);
  const [value, setValue] = useState('Unselected');
  const [selectedIndex, setIndex] = useState(undefined);

  const _onChange = event => {
    setIndex(event.nativeEvent.selectedSegmentIndex);
  };

  const _onValueChange = (value: string) => {
    setValue(value);
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.segmentContainer}>
        <Text style={styles.text}>Segmented controls can have values</Text>
        <SegmentedControl values={['One', 'Two']} />
      </View>

      <View style={styles.segmentSection}>
        <SegmentedControl values={['One', 'Two', 'Three', 'Four', 'Five']} />
      </View>

      <View style={styles.segmentSection}>
        <Text style={styles.text}>Segmented controls can have pre-selected values</Text>
        <SegmentedControl values={['One', 'Two']} selectedIndex={0} />
      </View>

      <View style={styles.segmentSection}>
        <Text style={styles.text}>Segmented controls can be momentary</Text>
        <SegmentedControl values={['One', 'Two']} momentary />
      </View>

      <View style={styles.segmentSection}>
        <Text style={styles.text}>Segmented controls can be disabled</Text>
        <SegmentedControl enabled={false} values={['One', 'Two']} selectedIndex={1} />
      </View>

      <View style={styles.segmentContainer}>
        <Text style={styles.text}>Custom colors can be provided</Text>
        <SegmentedControl
          tintColor="#ff0000"
          values={['One', 'Two', 'Three', 'Four']}
          selectedIndex={0}
          backgroundColor="#0000ff"
          activeTextColor="white"
        />
      </View>
      <View style={styles.segmentContainer}>
        <SegmentedControl
          tintColor="#00ff00"
          values={['One', 'Two', 'Three']}
          selectedIndex={1}
          activeTextColor="black"
        />
      </View>
      <View style={styles.segmentSection}>
        <SegmentedControl textColor="#ff00ff" values={['One', 'Two']} selectedIndex={1} />
      </View>

      <View>
        <Text style={styles.text}>Custom colors can be provided</Text>
        <View style={styles.segmentContainer}>
          <SegmentedControl
            values={values}
            selectedIndex={selectedIndex}
            onChange={_onChange}
            onValueChange={_onValueChange}
          />
        </View>
        <Text style={[styles.text]}>
          Value: {value} Index: {selectedIndex}
        </Text>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  text: {
    fontSize: 14,
    textAlign: 'center',
    fontWeight: '500',
    margin: 10,
  },
  segmentContainer: {
    marginBottom: 10,
  },
  segmentSection: {
    marginBottom: 25,
  },
  container: {
    paddingTop: 80,
  },
});

export default SegmentedControlScreen;
